class AccueilController < ApplicationController
  def index
  end

  def identification
    if params[:identifiant].empty? || params[:annee].empty? || params[:mois].empty? || params[:jour].empty?
      session[:message_erreur] = "Veuillez renseigner l'identifiant et la date de naissance de l'élève."
      redirect_to '/'
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
      session[:message_erreur] = "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
      redirect_to '/'
    end
  end

  def accueil
    eleve.dossier_eleve.update derniere_etape: 'accueil'
    @dossier_eleve = eleve.dossier_eleve
  end

  def normalise_alphanum chaine
    chaine.gsub(/[^[:alnum:]]/, '').upcase
  end

  def get_eleve
    eleve.dossier_eleve.update derniere_etape: 'eleve'
    @options_du_niveau = eleve.montee.present? ? eleve.montee.demandabilite.collect(&:option) : []
    @eleve = eleve
    render 'accueil/eleve'
  end

  def post_eleve
    eleve_a_modifier = eleve
    identite_eleve = ['prenom', 'prenom_2', 'prenom_3', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
    identite_eleve.each do |info|
     eleve_a_modifier[info] = params[info] if params.has_key?(info)
    end

    # Pour chaque option de l'élève, vérifier si elle doit être abandonnée
    options = eleve.montee.present? ? eleve.montee.abandonnabilite.collect(&:option) : []
    options.each do |option|
      if params["#{option.nom}_present"]
        abandon = Abandon.find_or_initialize_by(eleve: eleve, option: option)
        eleve_a_modifier.abandon.delete abandon if params[option.nom] == 'true'
        eleve_a_modifier.abandon << abandon if params[option.nom].nil?
      end
    end

    # Pour chacune des options vérifier si elle est choisie directement
    options = eleve.montee.present? ? eleve.montee.demandabilite.collect(&:option) : []
    options.each do |option|
      if params["#{option.nom}_present"]
        demande = Demande.find_or_initialize_by(eleve: eleve, option: option)
        eleve_a_modifier.demande.delete demande if params[option.nom].nil?
        eleve_a_modifier.demande << demande if params[option.nom] == 'true'
      end
    end

    # Ensuite on va itérer sur les groupes
    options.collect(&:groupe).uniq.each do |groupe|
      if params[groupe].present?
        # On découvre l'option retenue
        option_choisie = options.find {|option| option.nom == params[groupe]}
        demande = Demande.find_or_initialize_by(eleve: eleve, option: option_choisie)
        # On supprime les autres (choix mutuellement exclusif)
        eleve_a_modifier.demande.each do |demande_presente|
          eleve_a_modifier.demande.delete demande_presente if demande_presente.option.groupe == groupe
        end
        # On garde celle retenue
        eleve_a_modifier.demande << demande
      end
    end
    eleve_a_modifier.save!

    sauve_et_redirect eleve.dossier_eleve, 'famille'
  end

  def get_famille
    dossier_eleve = eleve.dossier_eleve
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
    @dossier_eleve = eleve.dossier_eleve
    render 'accueil/famille'
  end

  def post_famille
    dossier_eleve = eleve.dossier_eleve
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

  def get_dossier_eleve identifiant
    DossierEleve.joins(:eleve).find_by(eleves: {identifiant: identifiant})
  end

  def eleve
    Eleve.find_by(identifiant: session[:identifiant])
  end

  def code_situation
    {'0': '', '1': 'occupe un emploi', '2': 'Au chômage', '3': 'Pré retraité, retraité ou retiré', '4': 'Personne sans activité professionnelle'}
  end

  def sauve_et_redirect dossier_eleve, etape_la_plus_avancee
    dossier_eleve.etape_la_plus_avancee = etape_la_plus_avancee
    dossier_eleve.save!
    redirect_to "/#{etape_la_plus_avancee}"
  end
end
