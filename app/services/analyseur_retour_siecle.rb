# frozen_string_literal: true

class AnalyseurRetourSiecle

  def self.analyse(dossier)
    {
      "retour_siecles.dossier_non_valide" => -> { dossier.valide? },
      "retour_siecles.dossier_sans_mef_destination" => -> { dossier.mef_destination.present? },
      "retour_siecles.dossier_sans_mef_an_dernier" => -> { dossier.mef_an_dernier.present? },
      "retour_siecles.dossier_sans_nom_ou_prenom" => -> { dossier.prenom.present? && dossier.nom.present? },
      "retour_siecles.probleme_commune_naissance" => -> { commune_insee_renseigner_si_nee_en_france?(dossier) },
      "retour_siecles.dossier_avec_mef_origine_invalide" => -> { dossier.mef_origine.code.length == 11 },
      "retour_siecles.dossier_avec_mef_destination_invalide" => -> { dossier.mef_destination.code.length == 11 }
    }.each { |probleme, condition| return I18n.t(probleme) unless condition.call }

    ""
  end

  def self.commune_insee_renseigner_si_nee_en_france?(dossier)
    dossier.pays_naiss == "100" && dossier.commune_insee_naissance.present?
  end

  def self.analyse_dossiers!(dossiers)
    dossiers.each do |dossier|
      dossier.update(retour_siecle_impossible: analyse(dossier))
    end
  end

end
