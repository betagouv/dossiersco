require 'traitement'

class InscriptionsController < ApplicationController
  before_action :identification_agent, except: [:post_agent, :agent, :declenche_traiter_imports]
  layout 'layout_agent'

  def agent
    render :identification
  end

  def post_agent
    mon_agent = Agent.find_by(identifiant: params[:identifiant])

    if mon_agent && mon_agent.authenticate(params[:mot_de_passe])
      session[:identifiant] = mon_agent.identifiant
      redirect_to agent_liste_des_eleves_path
    else
      session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
      redirect_to agent_path
    end
  end

  def liste_des_eleves
    lignes_eleves = DossierEleve
      .joins(:eleve,:resp_legal)
      .select('dossier_eleves.id as dossier_id')
      .select('dossier_eleves.updated_at as dossier_maj')
      .select('dossier_eleves.*')
      .select('eleves.*')
      .select('resp_legals.email')
      .select('adresse,code_postal,ville,adresse_ant,code_postal_ant,ville_ant')
      .order('eleves.classe_ant DESC, dossier_eleves.etat, eleves.identifiant')
      .where(resp_legals:{priorite:1}, etablissement: get_agent.etablissement)
    pieces_jointes = PieceJointe
      .joins(:dossier_eleve,:piece_attendue)
      .select('dossier_eleves.id as dossier_id').select('piece_jointes.*')
      .where(piece_attendues:{etablissement_id: get_agent.etablissement.id})
      .group_by(&:dossier_eleve_id)
    messages = Message
      .joins(:dossier_eleve)
      .select('dossier_eleves.id as dossier_id').select('messages.dossier_eleve_id')
      .where(dossier_eleves:{etablissement_id: get_agent.etablissement.id})
      .group_by(&:dossier_eleve_id)
    message_info = session[:message_info]
    session.delete :message_info
    render :liste_des_eleves,
      locals: {
        agent: get_agent,
        lignes_eleves: lignes_eleves,
        message_info: message_info,
        messages: messages,
        pieces_attendues: get_agent.etablissement.piece_attendue,
        pieces_jointes: pieces_jointes}
  end

  def import_siecle
    tempfile = params[:filename].tempfile
    tempfile = tempfile.path if tempfile.respond_to? :path
    file = File.open(tempfile)
    uploader = FichierUploader.new
    uploader.store!(file)
    fichier_s3 = get_fichier_s3 File.basename(tempfile)
    tache = TacheImport.create(
        url: fichier_s3.url(Time.now.to_i + 1200),
        etablissement_id: get_agent.etablissement.id,
        statut: 'en_attente',
        nom_a_importer: params[:nom_eleve],
        prenom_a_importer: params[:prenom_eleve])
    render :import_siecle,
        locals: { message: "",
                  tache: tache
        }
  end

  def new_import_siecle
    tache = get_agent.etablissement.tache_import.last
    render :import_siecle, locals: {agent: get_agent, tache: tache, message: ""}
  end

  def declenche_traiter_imports
    traiter_imports
    head :ok
  end

  def change_etat_fichier
    piece = PieceJointe.find(params[:id])
    piece.update(etat: params[:etat])
    head :ok
  end

  def eleve
    eleve = Eleve.find_by(identifiant: params[:identifiant])
    dossier_eleve = eleve.dossier_eleve
    emails_presents = false
    resp_legaux = dossier_eleve.resp_legal
    resp_legaux.each { |r| (emails_presents = true) if r.email.present?}
    meme_adresse = resp_legaux.first.meme_adresse resp_legaux.second
    modeles = get_agent.etablissement.modele
    render :eleve,
      locals: {
      emails_presents: emails_presents,
      agent: get_agent,
      modeles: modeles,
      eleve: eleve,
      dossier_eleve: dossier_eleve,
      meme_adresse: meme_adresse}
  end

  def pieces_attendues
    etablissement = get_agent.etablissement
    piece_attendues = etablissement.piece_attendue
    render :piece_attendues, locals: {agent: get_agent, piece_attendues: piece_attendues}
  end

  def post_pieces_attendues
    etablissement = get_agent.etablissement
    code_piece = params[:nom].gsub(/[^a-zA-Z0-9]/, '_').upcase.downcase
    piece_attendue = PieceAttendue.find_by(
        code: code_piece,
        etablissement: etablissement.id)

    if !params[:nom].present?
      message = "Une pièce doit comporter un nom"
      render :piece_attendues, locals: {piece_attendues: etablissement.piece_attendue, message: message}
    elsif piece_attendue.present? && (piece_attendue.nom == code_piece)
      message = "#{params[:nom]} existe déjà"
      render :piece_attendues, locals: {piece_attendues: etablissement.piece_attendue, message: message}
    else
      piece_attendue = PieceAttendue.create!(
          nom: params[:nom],
          explication: params[:explication],
          obligatoire: params[:obligatoire],
          etablissement_id: etablissement.id,
          code: code_piece)
      render :piece_attendues,
          locals: {piece_attendues: etablissement.piece_attendue, agent: get_agent}
    end
  end

  def post_pdf
    eleve = Eleve.find_by identifiant: params[:identifiant]
    pdf = genere_pdf eleve
    agent = Agent.find_by(identifiant: session[:identifiant])
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end

  def valider_inscription
    eleve = Eleve.find_by identifiant: params[:identifiant]
    dossier_eleve = eleve.dossier_eleve
    emails = dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email }
    dossier_eleve.valide

    redirect_to "/agent/liste_des_eleves"
  end

  def eleve_sortant
    eleve = Eleve.find_by identifiant: params[:identifiant]
    dossier_eleve = eleve.dossier_eleve
    dossier_eleve.update(etat: 'sortant')

    redirect_to "/agent/liste_des_eleves"
  end

  def contacter_une_famille
    eleve = Eleve.find_by(identifiant: params[:identifiant])
    dossier_eleve = eleve.dossier_eleve
    emails_presents = false
    resp_legaux = dossier_eleve.resp_legal
    resp_legaux.each { |r| (emails_presents = true) if r.email.present?}
    session[:message_info] = "Votre message ne peut être acheminé."
    if emails_presents
      mail = AgentMailer.contacter_une_famille(eleve, params[:message])
      part = mail.html_part || mail.text_part || mail
      Message.create(categorie:"mail", contenu: part.body, etat: "envoyé", dossier_eleve: eleve.dossier_eleve)
      mail.deliver_now
      session[:message_info] = "Votre message a été envoyé."
    elsif dossier_eleve.portable_rl1.present?
      Message.create(categorie:"sms",
                     contenu: params[:message],
                     destinataire: params[:destinataire] || "rl1",
                     etat: "en attente",
                     dossier_eleve: eleve.dossier_eleve)
      session[:message_info] = "Votre message est en attente d'expédition."
    end
    redirect_to "/agent/liste_des_eleves"
  end

  def relance_emails
    template = params[:template]
    ids = params[:ids].split(',')
    dossier_eleves = []

    ids.each do |id|
      dossier = DossierEleve.find(id)
      template = Tilt['erb'].new { template }
      contenu = template.render(nil, eleve: dossier.eleve)
      Message.create(categorie:"mail",
                     contenu: contenu,
                     etat: "en attente",
                     dossier_eleve: dossier)
    end

    redirect_to '/agent/liste_des_eleves'
  end

  def fusionne_modele
    eleve = Eleve.find_by(identifiant: params[:identifiant])
    modele = Modele.find(params[:modele_id])
    template = Tilt['erb'].new { modele.contenu }
    template.render(nil, eleve: eleve)
  end

  def valider_plusieurs_dossiers
    ids = params["ids"]
    ids.each do |id|
      DossierEleve.find(id).valide
    end
    redirect_to '/agent/liste_des_eleves'
  end

  def options
    etablissement = get_agent.etablissement
    eleves_par_classe = DossierEleve.where(etablissement_id: etablissement.id).collect(&:eleve).group_by(&:niveau_classe_ant)
    eleves = Eleve.all.select {|e| e.dossier_eleve.etablissement_id == etablissement.id && e.dossier_eleve.etat != 'sortant'}
    nb_max_options = 0
    eleves.each do |e|
      nb_max_options = e.options_apres_montee.count if e.options_apres_montee.count > nb_max_options
    end

    render :options, locals: {agent: get_agent,etablissement: etablissement, eleves_par_classe: eleves_par_classe,
                                   eleves: eleves, nb_max_options: nb_max_options}
  end

  def convocations
    etablissement = get_agent.etablissement
    eleves = Eleve.all.select do |e|
      d = e.dossier_eleve
      d.etablissement_id == etablissement.id && (d.etat == 'pas connecté' || d.etat == 'connecté')
    end

    render :convocations, locals: {agent: get_agent,etablissement: etablissement, eleves: eleves}
  end

  def deconnexion
    reset_session
    redirect_to '/agent'
  end

  def tableau_de_bord
    total_dossiers = get_agent.etablissement.dossier_eleve.count
    etats, notes, moyenne, dossiers_avec_commentaires = get_agent.etablissement.stats
    render :tableau_de_bord,
        locals: {agent: get_agent, total_dossiers: total_dossiers, etats: etats,
                 notes: notes, moyenne: moyenne, dossiers_avec_commentaires: dossiers_avec_commentaires.sort_by(&:date_signature).reverse}
  end

  def post_tableau_de_bord
    get_agent.update(etablissement_id: params[:etablissement])
    redirect_to '/agent/tableau_de_bord'
  end

  def pieces_jointes_eleve
    eleve = Eleve.find_by(identifiant: params[:identifiant])
    dossier_eleve = eleve.dossier_eleve
    upload_pieces_jointes dossier_eleve, params, 'valide'
    redirect_to "/agent/eleve/#{eleve.identifiant}#dossier"
  end

  def export
    render :export, locals: {agent: get_agent}
  end

  def supprime_option
    Option.find(params[:option_id]).delete
    head ok
  end

  def supprime_piece_attendue
    pieces_existantes = PieceJointe.where(piece_attendue_id: params[:piece_attendue_id])
    if pieces_existantes.size >= 1
      message = 'Cette piece ne peut être supprimé'
      raise
    else
      PieceAttendue.find(params[:piece_attendue_id]).delete
    end
    head :ok
  end

  def relance
    ids = params["ids"].split(',')
    emails, telephones  = [], []

    ids.each do |id|
      dossier = DossierEleve.find(id)
      emails << dossier.resp_legal_1.email
      telephones << dossier.portable_rl1
    end

    render :relance,
        locals: {ids: ids, emails: emails, telephones: telephones}
  end

  def relance_sms
    template = params[:template]
    ids = params[:ids].split(',')
    ids.each do |id|
      DossierEleve.find(id).relance_sms template
    end
    redirect_to '/agent/liste_des_eleves'
  end
end
