# frozen_string_literal: true

class AccueilController < ApplicationController

  before_action :retrouve_eleve_connecte, except: %i[index identification stats]
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

    if dossier_eleve.present?
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

  def eleve
    @eleve.dossier_eleve.update derniere_etape: "eleve"
    @options_pedagogiques_selectionnees = @eleve.dossier_eleve.options_pedagogiques
    @options_pedagogiques = OptionPedagogique.filtre_par(@eleve.dossier_eleve.mef_destination)

    @option_origines_ids = @eleve.dossier_eleve.options_origines.map { |k, _v| k.to_i }
    render "accueil/eleve"
  end

  def post_eleve
    identite_eleve = %w[prenom prenom_2 prenom_3 nom sexe ville_naiss pays_naiss nationalite classe_ant ets_ant]
    identite_eleve.each do |info|
      @eleve[info] = params[info] if params.key?(info)
    end

    @eleve.dossier_eleve.options_pedagogiques = []
    @options_pedagogiques = OptionPedagogique.where(etablissement: @eleve.dossier_eleve.etablissement)
    @options_pedagogiques.each do |option|
      @eleve.dossier_eleve.options_pedagogiques << option if params[option.nom].present?
    end

    @eleve.save!

    @eleve.dossier_eleve.update!(etape_la_plus_avancee: "famille")
    redirect_to "/famille"
  end

  def famille
    @dossier_eleve = @eleve.dossier_eleve
    @dossier_eleve.update derniere_etape: "famille"
    @resp_legal1 = @dossier_eleve.resp_legal_1
    @resp_legal2 = @dossier_eleve.resp_legal_2
    @contact_urgence = @dossier_eleve.contact_urgence
    @lien_de_parentes = ["MERE", "PERE", "AUTRE FAM.", "AUTRE LIEN", "TUTEUR", "ASE"]

    @code_profession = RespLegal.codes_profession
    @code_situation = code_situation
    render "accueil/famille"
  end

  def post_famille
    dossier_eleve = @eleve.dossier_eleve
    resp_legal1 = dossier_eleve.resp_legal_1
    resp_legal2 = dossier_eleve.resp_legal_2
    contact_urgence = ContactUrgence.find_by(dossier_eleve_id: dossier_eleve.id) || ContactUrgence.new(dossier_eleve_id: dossier_eleve.id)

    RespLegal.identites.each do |i|
      resp_legal1[i] = params["#{i}_rl1"] if params.key?("#{i}_rl1")
      resp_legal2[i] = params["#{i}_rl2"] if resp_legal2 && params.key?("#{i}_rl2")
    end
    resp_legal1.save!
    resp_legal2.save! if resp_legal2.present?

    %w[lien_avec_eleve prenom nom tel_principal tel_secondaire].each do |i|
      contact_urgence[i] = params["#{i}_urg"] if params.key?("#{i}_urg")
    end
    contact_urgence.save!

    if responsables_valides?(resp_legal1, resp_legal2)
      sauve_et_redirect dossier_eleve, "administration"
    else
      error = if resp_legal1.errors.messages.present?
                resp_legal1.errors.messages.first[1].join
              elsif resp_legal2.present? && resp_legal2.errors.messages.present?
                resp_legal2.errors.messages.first[1].join
              end
      redirect_to famille_path, alert: error
    end
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
    @dossier_eleve = @eleve.dossier_eleve
  end

  def post_validation
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.signature = params[:signature]
    dossier_eleve.date_signature = Time.now
    dossier_eleve.save
    if dossier_eleve.etat != "validé"
      FamilleMailer.envoyer_mail_confirmation(dossier_eleve.eleve).deliver_now
      dossier_eleve.update(etat: "en attente de validation")
    end
    sauve_et_redirect dossier_eleve, "confirmation"
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
    dossier_eleve.save!
    sauve_et_redirect dossier_eleve, "pieces_a_joindre"
  end

  def deconnexion
    reset_session
    redirect_to "/"
  end

  def confirmation
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.update derniere_etape: "confirmation"
    render "confirmation", locals: { eleve: @eleve, dossier_eleve: dossier_eleve }
  end

  def satisfaction
    dossier_eleve = @eleve.dossier_eleve
    dossier_eleve.satisfaction = params[:note]
    dossier_eleve.save!
  end

  def pieces_a_joindre
    @eleve.dossier_eleve.update derniere_etape: "pieces_a_joindre"
    @pieces_jointes = @eleve.dossier_eleve.pieces_jointes
    render "pieces_a_joindre", locals: { dossier_eleve: @eleve.dossier_eleve }
  end

  def code_situation
    { '0': "", '1': "occupe un emploi", '2': "Au chômage", '3': "Pré retraité, retraité ou retiré", '4': "Personne sans activité professionnelle" }
  end

  def sauve_et_redirect(dossier_eleve, etape_la_plus_avancee)
    dossier_eleve.etape_la_plus_avancee = etape_la_plus_avancee
    dossier_eleve.save!
    redirect_to "/#{etape_la_plus_avancee}"
  end

  def post_pieces_a_joindre
    dossier_eleve = @eleve.dossier_eleve
    if dossier_eleve.pieces_manquantes?
      @pieces_jointes = dossier_eleve.pieces_jointes
      render :pieces_a_joindre, locals: { dossier_eleve: dossier_eleve, message: "Veuillez télécharger les pièces obligatoires" }
    else
      sauve_et_redirect dossier_eleve, "validation"
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
    render :stats, locals: { etablissements: etablissements }
  end

end
