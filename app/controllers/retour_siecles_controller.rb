# frozen_string_literal: true

class RetourSieclesController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin
  before_action :trouve_tache, only: %i[new manque_code_matiere manque_division]
  before_action :dossiers_sans_division, only: %i[manque_division export_des_dossiers]
  before_action :options_en_erreur, only: %i[new manque_code_matiere]

  def new
    options_en_erreur = @options_en_erreur.count.positive? ? true : false
    dossiers_sans_division unless options_en_erreur

    if options_en_erreur
      redirect_to manque_code_matiere_retour_siecle_path
    elsif @dossiers_sans_division.count.positive?
      redirect_to manque_division_retour_siecle_path
    else
      redirect_to export_des_dossiers_retour_siecle_path
    end
  end

  def manque_code_matiere
    @date_dernier_import_nomenclature = TacheImport.date_dernier_import_nomenclature(@etablissement)
  end

  def manque_division; end

  def export_des_dossiers
    @dossiers = dossiers_etablissement.exportables
    @nb_resp_legaux = nb_resp_legaux(@dossiers)
    @dossiers_bloques = []
    @dossiers_bloques
      .concat(extrait_informations(dossiers_etablissement.where(mef_destination: nil),
                                   I18n.t("retour_siecles.export_des_dossiers.dossier_sans_mef_destination")))
    @dossiers_bloques
      .concat(extrait_informations(eleves_sans_commune_insee,
                                   I18n.t("retour_siecles.export_des_dossiers.probleme_de_commune_insee")))
    @dossiers_bloques
      .concat(extrait_informations(resp_legal_probleme_profession,
                                   I18n.t("retour_siecles.export_des_dossiers.probleme_de_profession")))
    @dossiers_bloques
      .concat(extrait_informations(dossiers_etablissement.where(mef_an_dernier: nil),
                                   I18n.t("retour_siecles.export_des_dossiers.dossier_mef_an_dernier_inconnu")))
    @dossiers_bloques
      .concat(extrait_informations(dossiers_etablissement.avec_code_mef_origine_invalide,
                                   I18n.t("retour_siecles.export_des_dossiers.dossier_avec_mef_origine_invalide")))
    @dossiers_bloques
      .concat(extrait_informations(dossiers_etablissement.avec_code_mef_destination_invalide,
                                   I18n.t("retour_siecles.export_des_dossiers.dossier_avec_mef_destination_invalide")))

    return unless params[:liste_ine].present?

    ines = params[:liste_ine].split(",")
    @selection_dossiers = @dossiers.joins(:eleve).where("eleves.identifiant in (?)", ines)
    @dossiers_exportables = @selection_dossiers.exportables
    @nb_resp_legaux_selection = nb_resp_legaux(@dossiers_exportables)
  end

  def dossiers_etablissement
    DossierEleve.where(etablissement: @etablissement)
  end

  def eleves_sans_commune_insee
    dossiers_etablissement.joins(:eleve).where("eleves.commune_insee_naissance is null and eleves.pays_naiss = '100'")
  end

  def resp_legal_probleme_profession
    resp_legal_profession_null.or(resp_legal_profession_retraite_employe_ouvrier).or(resp_legal_retraite_cadre_intermediaire)
  end

  def resp_legal_profession_null
    dossiers_etablissement.joins(:eleve).joins(:resp_legal).where("resp_legals.profession is null")
  end

  def resp_legal_profession_retraite_employe_ouvrier
    dossiers_etablissement.joins(:eleve).joins(:resp_legal).where("resp_legals.profession = 'Retraité employé, ouvrier'")
  end

  def resp_legal_retraite_cadre_intermediaire
    dossiers_etablissement.joins(:eleve).joins(:resp_legal).where("resp_legals.profession = 'Retraité cadre, profession intermédiaire'")
  end

  def extrait_informations(dossiers, raison)
    dossier_bloque = Struct.new(:identifiant, :prenom, :nom, :raison)
    dossiers.map do |dossier|
      dossier_bloque.new(dossier.identifiant, dossier.prenom, dossier.nom, raison)
    end
  end

  private

  def nb_resp_legaux(dossiers)
    RespLegal.joins(:dossier_eleve).where(dossier_eleve: [dossiers.pluck(:id)]).count
  end

  def trouve_tache
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)
  end

  def options_en_erreur
    @options_en_erreur = OptionPedagogique.where(etablissement: @etablissement, code_matiere: [nil, ""])
  end

  def dossiers_sans_division
    @dossiers_sans_division = DossierEleve.where(etablissement: @etablissement, division: nil)
  end

end
