# frozen_string_literal: true

class AnalyseurRetourSiecle

  def self.analyse(dossier)
    return I18n.t("retour_siecles.dossier_non_valide") unless dossier.valide?
    return I18n.t("retour_siecles.dossier_sans_mef_destination") unless dossier.mef_destination.present?
    return I18n.t("retour_siecles.dossier_sans_mef_an_dernier") unless dossier.mef_an_dernier.present?
    return I18n.t("retour_siecles.dossier_sans_nom_ou_prenom") unless dossier.eleve.prenom.present?
    return I18n.t("retour_siecles.dossier_sans_nom_ou_prenom") unless dossier.nom.present?
    return I18n.t("retour_siecles.probleme_commune_naissance") unless commune_insee_renseigner_si_nee_en_france?(dossier)
    return I18n.t("retour_siecles.dossier_avec_mef_origine_invalide") unless dossier.mef_origine.code.length == 11
    return I18n.t("retour_siecles.dossier_avec_mef_destination_invalide") unless dossier.mef_destination.code.length == 11

    ""
  end

  def self.commune_insee_renseigner_si_nee_en_france?(dossier)
    dossier.eleve.pays_naiss == "100" && dossier.eleve.commune_insee_naissance.present?
  end

  def self.analyse_dossiers!(dossiers)
    dossiers.each do |dossier|
      dossier.update(retour_siecle_impossible: analyse(dossier))
    end
  end

end
