require 'traitement'

class AccueilController < ApplicationController
  before_action :retrouve_élève_connecté, except: [:index, :identification, :stats]

  def index
  end

  def identification
    if params[:identifiant].empty? || params[:annee].empty? || params[:mois].empty? || params[:jour].empty?
      session[:message_erreur] = t('identification.erreurs.identifiants_non_renseignes')
      redirect_to '/'
      return
    end
    Trace.create(identifiant: params[:identifiant],
                 categorie: 'famille',
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
    identifiant = normalise_alphanum params[:identifiant]
    dossier_eleve = get_dossier_eleve identifiant

    date_saisie = "#{params[:annee]}-#{params[:mois]}-#{params[:jour]}"
    if dossier_eleve.present? && (dossier_eleve.eleve.date_naiss == date_saisie)
      if dossier_eleve.etat == 'pas connecté'
        dossier_eleve.update(etat: 'connecté')
      end
      session[:identifiant] = identifiant
      if dossier_eleve.derniere_etape.present?
        redirect_to "/#{dossier_eleve.derniere_etape}"
      elsif dossier_eleve.etape_la_plus_avancee.present?
        redirect_to "/#{dossier_eleve.etape_la_plus_avancee}"
      else
        redirect_to "accueil"
      end

    else
      # Emettre un message générique quelle que soit l'erreur pour éviter
      # de "fuiter" de l'information sur l'existence ou non des identifiants
      session[:message_erreur] = t('identification.erreurs.identifiants_inconnus')
      redirect_to '/'
    end
  end

  def accueil
    @eleve.dossier_eleve.update derniere_etape: 'accueil'
    @dossier_eleve = @eleve.dossier_eleve
  end

  def normalise_alphanum chaine
    chaine.gsub(/[^[:alnum:]]/, '').upcase
  end

  def get_eleve
    @eleve.dossier_eleve.update derniere_etape: 'eleve'
    @options_pedagogiques = OptionPedagogique.joins(:mef).where(mef: {id: @eleve.dossier_eleve.mef_destination.id})
    @options_du_niveau = @eleve.montee.present? ? @eleve.montee.demandabilite.collect(&:option) : []
    render 'accueil/eleve'
  end

  def post_eleve
    identite_eleve = ['prenom', 'prenom_2', 'prenom_3', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
    identite_eleve.each do |info|
      @eleve[info] = params[info] if params.has_key?(info)
    end

    options = @eleve.montee.present? ? @eleve.montee.abandonnabilite.collect(&:option) : []
    options.each do |option|
      if params["#{option.nom}_present"]
        abandon = Abandon.find_or_initialize_by(eleve: @eleve, option: option)
        @eleve.abandon.delete abandon if params[option.nom] == 'true'
        @eleve.abandon << abandon if params[option.nom].nil?
      end
    end

    @eleve.demande = []
    options_demandees = @eleve.montee.present? ? @eleve.montee.demandabilite.collect(&:option) : []

    options_demandees.each do |option|
      if params["#{option.nom}_present"]
        demande = Demande.find_or_initialize_by(eleve: @eleve, option: option)
        @eleve.demande.delete demande if params[option.nom].nil?
        @eleve.demande << demande if params[option.nom] == 'true'
      end
    end

    options_demandees.collect(&:groupe).uniq.each do |groupe|
      if params[groupe].present?
        option_choisie = options_demandees.find {|option| option.nom == params[groupe]}
        demande = Demande.find_or_initialize_by(eleve: @eleve, option: option_choisie)
        @eleve.demande << demande
      end
    end

    @eleve.save!

    @eleve.dossier_eleve.update!(etape_la_plus_avancee: 'famille')
    redirect_to "/#{'famille'}"
  end

  def get_famille
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.update derniere_etape: 'famille'
    resp_legal1 = dossier_eleve.resp_legal_1
    resp_legal2 = dossier_eleve.resp_legal_2
    contact_urgence = dossier_eleve.contact_urgence
    contact_urgence = nil if contact_urgence.present? && ! dossier_eleve.contact_urgence.nom.present?
    lien_de_parentes = ['MERE', 'PERE', 'AUTRE FAM.', 'AUTRE LIEN', 'TUTEUR', 'ASE']

    @resp_legal_1 = resp_legal1
    @resp_legal_2 = resp_legal2
    @contact_urgence = contact_urgence
    @code_profession = RespLegal.codes_profession
    @code_situation = code_situation
    @lien_de_parentes = lien_de_parentes
    @dossier_eleve = @eleve.dossier_eleve
    render 'accueil/famille'
  end

  def post_famille
    dossier_eleve = @eleve.dossier_eleve
    resp_legal1 = dossier_eleve.resp_legal_1
    resp_legal2 = dossier_eleve.resp_legal_2
    contact_urgence = ContactUrgence.find_by(dossier_eleve_id: dossier_eleve.id) || ContactUrgence.new(dossier_eleve_id: dossier_eleve.id)

    RespLegal.identites.each do |i|
      resp_legal1[i] = params["#{i}_rl1"] if params.has_key?("#{i}_rl1")
      resp_legal2[i] = params["#{i}_rl2"] if resp_legal2 && params.has_key?("#{i}_rl2")
      contact_urgence[i] = params["#{i}_urg"] if params.has_key?("#{i}_urg")
    end

    resp_legal1.save!
    resp_legal2.save! if resp_legal2
    contact_urgence.save!
    sauve_et_redirect dossier_eleve, 'administration'
  end

  def validation
    render 'validation', locals: { eleve: @eleve, dossier_eleve: @eleve.dossier_eleve }
  end

  def post_validation
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.signature = params[:signature]
    dossier_eleve.date_signature = Time.now
    dossier_eleve.save
    if dossier_eleve.etat != 'validé'
      mail = AgentMailer.envoyer_mail_confirmation(dossier_eleve.eleve)
      mail.deliver_now
      dossier_eleve.update(etat: 'en attente de validation')
    end
    sauve_et_redirect dossier_eleve, 'confirmation'
  end

  def get_dossier_eleve identifiant
    DossierEleve.joins(:eleve).find_by(eleves: {identifiant: identifiant})
  end

  def administration
    @eleve.dossier_eleve.update derniere_etape: 'administration'
    render 'administration', locals: {dossier_eleve: @eleve.dossier_eleve}
  end

  def post_administration
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.demi_pensionnaire = params['demi_pensionnaire']
    dossier_eleve.autorise_sortie = params['autorise_sortie']
    dossier_eleve.renseignements_medicaux = params['renseignements_medicaux']
    dossier_eleve.check_paiement_cantine = params['check_paiement_cantine']
    dossier_eleve.save!
    sauve_et_redirect dossier_eleve, 'pieces_a_joindre'
  end

  def deconnexion
    reset_session
    redirect_to '/'
  end

  def confirmation
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.update derniere_etape: 'confirmation'
    render 'confirmation', locals: { eleve: @eleve, dossier_eleve: dossier_eleve }
  end

  def satisfaction
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.satisfaction = params[:note]
    dossier_eleve.save!
  end

  def pieces_a_joindre
    @eleve.dossier_eleve.update derniere_etape: 'pieces_a_joindre'
    @pieces_jointes = @eleve.dossier_eleve.pieces_jointes
    render 'pieces_a_joindre', locals: {dossier_eleve: @eleve.dossier_eleve}
  end

  def code_situation
    {'0': '', '1': 'occupe un emploi', '2': 'Au chômage', '3': 'Pré retraité, retraité ou retiré', '4': 'Personne sans activité professionnelle'}
  end

  def sauve_et_redirect dossier_eleve, etape_la_plus_avancee
    dossier_eleve.etape_la_plus_avancee = etape_la_plus_avancee
    dossier_eleve.save!
    redirect_to "/#{etape_la_plus_avancee}"
  end

  def piece
    dossier_eleve = get_dossier_eleve params[:dossier_eleve]

    # Vérifier les droits d'accès
    famille_autorisé = params[:dossier_eleve] == session[:identifiant]

    agent = Agent.find_by(identifiant: session[:identifiant])
    agent_autorisé = agent.present? and (dossier_eleve.etablissement == agent.etablissement)

    usager_autorisé = famille_autorisé || agent_autorisé

    objet_demandé = params[:s3_key]
    objet_présent = PieceJointe.find_by(dossier_eleve_id: dossier_eleve.id, clef: params[:s3_key])
    clef_objet_présent = objet_présent.clef if objet_présent.present?
    objet_conforme = objet_demandé == clef_objet_présent

    if usager_autorisé and objet_conforme
      extension = objet_présent.ext
      fichier = get_fichier_s3(objet_demandé)
      if extension == 'pdf'
        content_type 'application/pdf'
      elsif extension == 'jpg' or extension == 'jpeg'
        content_type 'image/jpeg'
      elsif extension == 'png'
        content_type 'image/png'
      end
      send_data fichier.url(Time.now.to_i + 30)
    else
      redirect_to '/'
    end
  end

  def post_pieces_a_joindre
    dossier_eleve = @eleve.dossier_eleve
    pieces_attendues = dossier_eleve.etablissement.piece_attendue
    pieces_obligatoires = false
    pieces_attendues.each do |piece|
      piece_jointe = piece.piece_jointe
      if !piece_jointe.present? && piece.obligatoire
        pieces_obligatoires = true
      end
    end
    if pieces_obligatoires
      render :pieces_a_joindre, locals: {dossier_eleve: dossier_eleve, message: 'Veuillez télécharger les pièces obligatoires'}
    else
      sauve_et_redirect dossier_eleve, 'validation'
    end
  end

  def commentaire
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.commentaire = params[:commentaire]
    dossier_eleve.save!
    head :ok
  end

  def stats
    etablissements = Etablissement.all.sort_by {|e| e.dossier_eleve.count}.reverse
    render :stats, locals: {etablissements: etablissements}
  end
end
