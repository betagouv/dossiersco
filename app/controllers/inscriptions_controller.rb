require 'traitement'

class InscriptionsController < ApplicationController
  before_action :identification, except: [:post_agent, :agent, :declenche_traiter_imports]
  layout 'layout_agent'

  def agent
    render :identification
  end

  def post_agent
    mon_agent = Agent.find_by(identifiant: params[:identifiant])
    mdp_saisi = params[:mot_de_passe]
    if mon_agent && (BCrypt::Password.new(mon_agent.password) == mdp_saisi)
      session[:identifiant] = mon_agent.identifiant
      redirect_to '/agent/liste_des_eleves'
    else
      session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
      redirect_to '/agent'
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
        prenom_a_importer: params[:prenom_eleve],
        traitement: params[:traitement])
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

  private
  def get_agent
    @agent ||= Agent.find_by(identifiant: session[:identifiant])
  end

  def identification
    agent_connecte = get_agent
    identifiant = agent_connecte.present? ? agent_connecte.identifiant : '<anonyme>'
    Trace.create(identifiant: identifiant,
                 categorie: 'agent',
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
    redirect_to '/agent' unless agent_connecte.present?
  end
end
