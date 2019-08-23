# frozen_string_literal: true

class RetourSieclesController < ApplicationController

  layout "configuration"

  before_action :identification_agent
  before_action :if_agent_is_admin

  def new
    @tache = agent_connecte.etablissement.tache_import.last || TacheImport.new(etablissement: agent_connecte.etablissement)

    @options_en_erreur = OptionPedagogique.where(etablissement: @etablissement, code_matiere_6: [nil, ""])
    render(:manque_code_matiere) && return if @options_en_erreur.count.positive?

    @dossiers_sans_division = DossierEleve.where(etablissement: @etablissement, division: nil)
    render(:manque_division) && return if @dossiers_sans_division.count.positive? && !params[:bypass_manque_division]

    @dossiers = dossiers_etablissement.where.not(mef_destination_id: [nil, ""]).where(etat: DossierEleve::ETAT[:valide])
    @dossiers_bloques = []
    @dossiers_bloques.concat(extrait_informations(dossiers_etablissement.where(mef_destination: nil), I18n.t("retour_siecles.new.dossier_sans_mef_destination")))
    @dossiers_bloques.concat(extrait_informations(eleves_sans_commune_insee, I18n.t("retour_siecles.new.probleme_de_commune_insee")))
    @dossiers_bloques.concat(extrait_informations(resp_legal_probleme_profession, I18n.t("retour_siecles.new.probleme_de_profession")))

    if params[:liste_ine].present?
      ines = params[:liste_ine].split(",")
      @selection_dossiers = @dossiers.joins(:eleve).where("eleves.identifiant in (?)", ines)
    end
  end

  def dossiers_etablissement
    DossierEleve.where(etablissement: @etablissement)
  end

  def eleves_sans_commune_insee
    dossiers_etablissement.joins(:eleve).where("eleves.commune_insee_naissance is null")
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
      dossier_bloque.new(dossier.eleve.identifiant, dossier.eleve.prenom, dossier.eleve.nom, raison)
    end
  end

end
