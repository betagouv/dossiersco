class InscriptionsController < ApplicationController
  before_action :identification_agent, except: [:post_agent, :agent]
  layout 'agent'

  def agent
    render :identification, layout: 'connexion'
  end

  def post_agent
    mon_agent = Agent.find_by(email: params[:email].downcase)

    if mon_agent && mon_agent.authenticate(params[:mot_de_passe])
      session[:agent_email] = mon_agent.email
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
      .where(resp_legals:{priorite:1}, etablissement: agent_connecté.etablissement)
    pieces_jointes = PieceJointe
      .joins(:dossier_eleve,:piece_attendue)
      .select('dossier_eleves.id as dossier_id').select('pieces_jointes.*')
      .where(pieces_attendues: {etablissement_id: agent_connecté.etablissement.id})
      .group_by(&:dossier_eleve_id)
    messages = Message
      .joins(:dossier_eleve)
      .select('dossier_eleves.id as dossier_id').select('messages.dossier_eleve_id')
      .where(dossier_eleves:{etablissement_id: agent_connecté.etablissement.id})
      .group_by(&:dossier_eleve_id)
    message_info = session[:message_info]
    session.delete :message_info
    render :liste_des_eleves,
      locals: {
        agent: agent_connecté,
        lignes_eleves: lignes_eleves,
        message_info: message_info,
        messages: messages,
        pieces_attendues: agent_connecté.etablissement.pieces_attendues,
        pieces_jointes: pieces_jointes}
  end

  def eleve
    @dossier_eleve = Eleve.find_by(identifiant: params[:identifiant]).dossier_eleve
    @pieces_jointes = @dossier_eleve.pieces_jointes
    @emails_presents = false
    @dossier_eleve.resp_legal.each { |r| (@emails_presents = true) if r.email.present?}
    @meme_adresse = @dossier_eleve.resp_legal.first.meme_adresse @dossier_eleve.resp_legal.second
    @modeles = agent_connecté.etablissement.modele
    render :eleve
  end

  def modifier_mef_eleve
    @dossier_eleve = DossierEleve.find(params[:dossier_eleve_id])
    params_mef = params.require(:dossier_eleve).permit(:mef_destination_id, :mef_origine_id)
    if @dossier_eleve.update(params_mef)
      respond_to do |format|
        format.html { redirect_to "/agent/eleve/#{@dossier_eleve.eleve.identifiant}" }
        flash[:notice_mef] = t('.changements_enregistres')
        format.js {render :layout => false}
      end
    else
      respond_to do |format|
        format.html { redirect_to "/agent/eleve/#{@dossier_eleve.eleve.identifiant}" }
        flash[:alert_mef] = t('.changements_non_enregistres')
        format.js {render :layout => false}
      end
    end
  end

  def valider_inscription
    eleve = Eleve.find_by identifiant: params[:identifiant]
    dossier_eleve = eleve.dossier_eleve
    emails = dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email }
    dossier_eleve.valide!
    mail = FamilleMailer.mail_validation_inscription(eleve, @agent_connecté)
    mail.deliver_now

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
      mail = FamilleMailer.contacter_une_famille(eleve, @agent_connecté, params[:message])
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
      dossier_eleve = DossierEleve.find(id)
      dossier_eleve.valide!
      mail = FamilleMailer.mail_validation_inscription(dossier_eleve.eleve, @agent_connecté)
      mail.deliver_now
    end
    redirect_to '/agent/liste_des_eleves'
  end

  def convocations
    etablissement = agent_connecté.etablissement
    eleves = DossierEleve.pour(etablissement).a_convoquer.map(&:eleve)
    render :convocations, locals: {agent: agent_connecté, etablissement: etablissement, eleves: eleves}
  end

  def deconnexion
    reset_session
    redirect_to '/agent'
  end

  def tableau_de_bord
    total_dossiers = agent_connecté.etablissement.dossier_eleve.count
    etats, notes, moyenne, dossiers_avec_commentaires = agent_connecté.etablissement.stats
    render :tableau_de_bord,
      locals: {agent: agent_connecté, total_dossiers: total_dossiers, etats: etats,
               notes: notes, moyenne: moyenne, dossiers_avec_commentaires: dossiers_avec_commentaires.sort_by(&:date_signature).reverse}
  end

  def pieces_jointes_eleve
    eleve = Eleve.find_by(identifiant: params[:identifiant])
    dossier_eleve = eleve.dossier_eleve
    upload_pieces_jointes dossier_eleve, params, 'valide'
    redirect_to "/agent/eleve/#{eleve.identifiant}#dossier"
  end

  def export
    render :export, locals: {agent: agent_connecté}
  end

  def supprime_option
    Option.find(params[:option_id]).delete
    head ok
  end

  def supprime_piece_attendue
    pieces_existantes = PieceJointe.where(piece_attendue_id: params[:piece_attendue_id])
    if pieces_existantes.size >= 1
      message = 'Cette piece ne peut être supprimé'
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
