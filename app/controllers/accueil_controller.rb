# frozen_string_literal: true

require "csv"

class AccueilController < ApplicationController

  before_action :retrouve_eleve_connecte, except: %i[index identification stats]
  before_action :entrees_de_menu

  layout "famille"

  def index
    render layout: "connexion"
  end

  def identification
    if params[:identifiant].empty? || params[:annee].empty? || params[:mois].empty? || params[:jour].empty?
      flash[:erreur] = t("identification.erreurs.identifiants_non_renseignes")
      redirect_to root_path
      return
    end

    Trace.create(identifiant: params[:identifiant], categorie: "famille", page_demandee: request.path_info, adresse_ip: request.ip)

    dossier_eleve = DossierEleve.par_authentification(params[:identifiant], params[:jour], params[:mois], params[:annee])

    if dossier_eleve.present? &&
       dossier_eleve.etablissement.date_debut.present? &&
       dossier_eleve.etablissement.date_debut > Time.now
      flash[:erreur] = t("identification.erreurs.avant_date_debut",
                         date: dossier_eleve.etablissement.date_debut.strftime("%d/%m/%Y"))
      redirect_to root_path
    elsif dossier_eleve.present?
      dossier_eleve.update(etat: "connecté") if dossier_eleve.etat == "pas connecté"
      session[:identifiant] = params[:identifiant]

      if dossier_eleve.derniere_etape.present?
        redirect_to "/#{dossier_eleve.derniere_etape}"
      elsif dossier_eleve.etape_la_plus_avancee.present?
        redirect_to "/#{dossier_eleve.etape_la_plus_avancee}"
      else
        redirect_to "accueil"
      end

    else
      flash[:erreur] = t("identification.erreurs.identifiants_inconnus")
      redirect_to root_path
    end
  end

  def accueil
    @eleve.dossier_eleve.update derniere_etape: "accueil"
    @dossier_eleve = @eleve.dossier_eleve
  end

  def post_accueil
    note_avancement_et_redirige_vers("eleve")
  end

  def eleve
    @eleve.dossier_eleve.update derniere_etape: "eleve"
    @dossier_eleve = @eleve.dossier_eleve
    @options_pedagogiques = @dossier_eleve.mef_destination&.options_pedagogiques

    @option_origines_ids = @dossier_eleve.options_origines.map { |k, _v| k.to_i }

    @liste_pays = []
    pays = YAML.safe_load(File.read(File.join(Rails.root, "/app/jobs/code_pays.yml")))
    pays.each do |code_pays, libelle_pays|
      @liste_pays << [libelle_pays, code_pays]
    end

    @liste_nationalite = []
    pays = YAML.safe_load(File.read(File.join(Rails.root, "/app/jobs/code_nationalite.yml")))
    pays.each do |code_pays, libelle_pays|
      @liste_nationalite << [libelle_pays, code_pays]
    end

    render "accueil/eleve"
  end

  def post_eleve
    if @eleve.update(params_eleve)
      dossier_eleve = @eleve.dossier_eleve
      dossier_eleve.options_pedagogiques = []
      @options_pedagogiques = OptionPedagogique.where(etablissement: dossier_eleve.etablissement)
      @options_pedagogiques.each do |option|
        dossier_eleve.options_pedagogiques << option if params[option.nom].present?
      end

      options_origines = dossier_eleve.options_origines.keys.map { |o| OptionPedagogique.find_by(id: o) }.compact

      options_origines.each do |option|
        dossier_eleve.options_pedagogiques << option if abandonnable?(dossier_eleve, option)
      end

      note_avancement_et_redirige_vers("famille")
    else
      render :eleve
    end
  end

  def params_eleve
    params.require(:eleve).permit!
  end

  def famille
    @dossier_eleve = @eleve.dossier_eleve
    @dossier_eleve.update derniere_etape: "famille"
    @dossier_eleve.resp_legal << RespLegal.new(priorite: 2) if @dossier_eleve.resp_legal.count < 2
    @dossier_eleve.resp_legal.sort_by(&:priorite)
    @dossier_eleve.contact_urgence = @dossier_eleve.contact_urgence || ContactUrgence.new
    @contact_urgence = @dossier_eleve.contact_urgence
    variables_famille
    render "accueil/famille"
  end

  def variables_famille
    @code_situation = code_situation
    @liste_pays = []
    pays = YAML.safe_load(File.read(File.join(Rails.root, "/app/jobs/code_pays.yml")))
    pays.each do |code_pays, libelle_pays|
      @liste_pays << [libelle_pays, code_pays]
    end
  end

  def post_famille
    @dossier_eleve = @eleve.dossier_eleve

    valide = true
    save_dossier = @dossier_eleve.update(params_dossier_famille)
    @dossier_eleve.resp_legal.each { |resp| valide = false unless resp.valid? }
    if save_dossier && valide
      note_avancement_et_redirige_vers("administration")
    else
      variables_famille
      @affiche_formulaire = true
      render :famille
    end
  end

  def params_dossier_famille
    params.require(:dossier_eleve).permit(resp_legal_attributes: %i[lien_de_parente prenom nom code_postal
                                                                    adresse ville ville_etrangere pays
                                                                    tel_personnel tel_portable
                                                                    tel_professionnel email profession
                                                                    communique_info_parents_eleves
                                                                    enfants_a_charge id ],
                                          contact_urgence_attributes: %i[lien_avec_eleve prenom nom tel_principal
                                                                         tel_secondaire])
  end

  def responsables_valides?(resp_legal1, resp_legal2)
    resp_legal2_valide = if params["prenom_rl2"].present? && resp_legal2.resp_legal_valid?
                           true
                         elsif !params["prenom_rl2"].present?
                           true
                         else
                           false
                         end
    resp_legal1.resp_legal_valid? && resp_legal2_valide
  end

  def validation
    @eleve.dossier_eleve.update derniere_etape: "validation"
    @dossier_eleve = @eleve.dossier_eleve
    analyseur = AnalyseurOption.new(@dossier_eleve)
    @options_maintenues = analyseur.option_maintenue
    @options_demandees = analyseur.option_demandee
    @options_abandonnees = analyseur.option_abandonnee
  end

  def post_validation
    @dossier_eleve = @eleve.dossier_eleve
    @dossier_eleve.signature = params[:signature]
    @dossier_eleve.date_validation_famille = @dossier_eleve.date_validation_famille ||= Time.now
    @dossier_eleve.save
    if @dossier_eleve.etat != "validé"
      mail = FamilleMailer.envoyer_mail_confirmation(@dossier_eleve.eleve)
      part = mail.html_part || mail.text_part || mail
      Message.create(categorie: "mail", contenu: part.body, etat: "envoyé", dossier_eleve: @dossier)
      mail.deliver_now
      @dossier_eleve.update(etat: "en attente de validation")
    end
    redirect_to "/confirmation"
  end

  def confirmation
    @dossier_eleve = @eleve.dossier_eleve
    render "confirmation"
  end

  def administration
    @eleve.dossier_eleve.update derniere_etape: "administration"
    @dossier_eleve = @eleve.dossier_eleve
    render "administration"
  end

  def post_administration
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.demi_pensionnaire = params["demi_pensionnaire"]
    dossier_eleve.regime_sortie = RegimeSortie.find(params["regime_sortie"].to_i) if params["regime_sortie"].present?
    dossier_eleve.renseignements_medicaux = params["renseignements_medicaux"]
    dossier_eleve.check_paiement_cantine = params["check_paiement_cantine"]
    dossier_eleve.autorise_photo_de_classe = params["droit_image_photo"]
    dossier_eleve.identifiant_caf = params["identifiant_caf"]
    dossier_eleve.save!

    note_avancement_et_redirige_vers("pieces_a_joindre")
  end

  def deconnexion
    reset_session
    redirect_to "/"
  end

  def continuer_dossiersco
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.continuer_dossiersco = params[:continuer_dossiersco]
    dossier_eleve.save!
  end

  def satisfaction
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.satisfaction = params[:note]
    dossier_eleve.save!
  end

  def pieces_a_joindre
    @eleve.dossier_eleve.update derniere_etape: "pieces_a_joindre"
    @pieces_jointes = @eleve.dossier_eleve.pieces_jointes
    @dossier_eleve = @eleve.dossier_eleve
    render "pieces_a_joindre"
  end

  def code_situation
    { '0': "", '1': "occupe un emploi", '2': "Au chômage", '3': "Pré retraité, retraité ou retiré", '4': "Personne sans activité professionnelle" }
  end

  def post_pieces_a_joindre
    @dossier_eleve = @eleve.dossier_eleve
    if @dossier_eleve.pieces_manquantes?
      @pieces_jointes = @dossier_eleve.pieces_jointes
      flash[:erreur] = "Veuillez télécharger les pièces obligatoires"
      render :pieces_a_joindre
    else
      note_avancement_et_redirige_vers("validation")
    end
  end

  def commentaire
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.commentaire = params[:commentaire]
    dossier_eleve.save!
    head :ok
  end

  def stats
    etablissements = Etablissement.all.sort_by { |e| e.dossier_eleve.count }.reverse
    render :stats, locals: { etablissements: etablissements }, layout: "connexion"
  end

  def note_avancement_et_redirige_vers(page_destination)
    @eleve.dossier_eleve.update!(derniere_etape: page_destination)

    index_entree_menu = @entrees_de_menu.index(page_destination)
    index_entree_menu ||= 0
    index_etape_la_plus_avancee = @entrees_de_menu.index(@eleve.dossier_eleve.etape_la_plus_avancee)
    index_etape_la_plus_avancee ||= 0

    @eleve.dossier_eleve.update!(etape_la_plus_avancee: page_destination) if index_entree_menu > index_etape_la_plus_avancee

    redirect_to "/#{page_destination}"
  end

  def entrees_de_menu
    @entrees_de_menu = %w[accueil eleve famille administration pieces_a_joindre validation].freeze
  end

  def abandonnable?(dossier, option)
    !option.abandonnable?(dossier.mef_destination) &&
      !dossier.options_pedagogiques.include?(option)
  end

end
