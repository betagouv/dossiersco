# frozen_string_literal: true

require "test_helper"

class AnalyseurRetourSiecleTest < ActiveSupport::TestCase

  test "Un dossier invalide n'est pas exportable" do
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente_de_validation])
    assert_equal I18n.t("retour_siecles.dossier_non_valide"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier sans mef de destination n'est pas exportable" do
    dossier = Fabricate(:dossier_eleve_valide, mef_destination: nil)
    assert_equal I18n.t("retour_siecles.dossier_sans_mef_destination"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier sans mef de l'an dernier n'est pas exportable" do
    dossier = Fabricate(:dossier_eleve_valide, mef_an_dernier: nil)
    assert_equal I18n.t("retour_siecles.dossier_sans_mef_an_dernier"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier dont le prénom est vide n'est pas exportable" do
    dossier = Fabricate(:dossier_eleve_valide, mef_an_dernier: "12345678901", prenom: nil)
    assert_equal I18n.t("retour_siecles.dossier_sans_nom_ou_prenom"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier dont le nom est vide n'est pas exportable" do
    dossier = Fabricate(:dossier_eleve_valide, mef_an_dernier: "12345678901", nom: "")
    assert_equal I18n.t("retour_siecles.dossier_sans_nom_ou_prenom"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Si l'élève est né en france, il doit avoir une commune insee de naissance pour être exportable" do
    dossier = Fabricate(:dossier_eleve_valide, mef_an_dernier: "12345678901", pays_naiss: "100", commune_insee_naissance: nil)
    assert_equal I18n.t("retour_siecles.probleme_commune_naissance"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier dont le code mef origine n'est pas sur 11 caractères n'est pas exportable" do
    mef_code_pas_onze = Fabricate(:mef, code: "1234567890")
    dossier = Fabricate(:dossier_eleve_valide, mef_origine: mef_code_pas_onze)
    assert_equal I18n.t("retour_siecles.dossier_avec_mef_origine_invalide"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "Un dossier dont le code mef de destination n'est pas sur 11 caractères n'est pas exportable" do
    mef_code_pas_onze = Fabricate(:mef, code: "1234567890")
    dossier = Fabricate(:dossier_eleve_valide, mef_destination: mef_code_pas_onze, mef_origine: Fabricate(:mef))
    assert_equal I18n.t("retour_siecles.dossier_avec_mef_destination_invalide"), AnalyseurRetourSiecle.analyse(dossier)
  end

  test "mets à jours la raison du blocage siecle à partir d'une collection" do
    dossiers = [Fabricate(:dossier_eleve_valide), Fabricate(:dossier_eleve)]
    AnalyseurRetourSiecle.analyse_dossiers!(dossiers)
    assert_equal [I18n.t("retour_siecles.dossier_non_valide"), ""].sort, dossiers.map(&:retour_siecle_impossible).sort
  end

end
