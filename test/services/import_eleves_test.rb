# frozen_string_literal: true

require "test_helper"

class ImportElevesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "enregistre les données élèves" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    dossier = Fabricate(:dossier_eleve, identifiant: "070832327JA", ville_naiss: "blu", commune_insee_naissance: nil)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportEleves.new.perform(tache)
      dossier.reload
      assert_equal "10210001110", dossier.mef_an_dernier
      assert_equal "4 D", dossier.division_an_dernier
      assert_equal "3 A", dossier.division
      assert_equal "93066", dossier.commune_insee_naissance
      assert_equal "ST DENIS", dossier.ville_naiss
    end
  end

  test "n'écrase pas les données présente" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    dossier = Fabricate(:dossier_eleve, identifiant: "070832327JA", ville_naiss: "Saint Denis", commune_insee_naissance: "93066")

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportEleves.new.perform(tache)
      dossier.reload
      assert_equal "93066", dossier.commune_insee_naissance
      assert_equal "Saint Denis", dossier.ville_naiss
    end
  end

  test "récolte le ID_PRV_ELE du fichier avec l'élève" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    dossier = Fabricate(:dossier_eleve, identifiant: "060375611AC", id_prv_ele: nil)
    autre_dossier = Fabricate(:dossier_eleve, identifiant: "070832327JA", id_prv_ele: nil)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)
    dossier.reload
    assert_equal "9065", dossier.id_prv_ele
    autre_dossier.reload
    assert_nil autre_dossier.id_prv_ele
  end

  test "récolte PRENOM2 et PRENOM3" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    dossier_avec_3_prenoms = Fabricate(:dossier_eleve, identifiant: "060375611AC")

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)
    dossier_avec_3_prenoms.reload
    assert_equal "PRENOM2", dossier_avec_3_prenoms.prenom_2
    assert_equal "PRENOM3", dossier_avec_3_prenoms.prenom_3
  end

  test "préserve des PRENOM2 et PRENOM3 renseignés dans DossierSCO" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    dossier_avec_3_prenoms = Fabricate(:dossier_eleve, identifiant: "060375611AC", prenom_2: "Prénom 2 DossierSCO", prenom_3: "Prénom 3 DossierSCO")

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)
    dossier_avec_3_prenoms.reload
    assert_equal "Prénom 2 DossierSCO", dossier_avec_3_prenoms.prenom_2
    assert_equal "Prénom 3 DossierSCO", dossier_avec_3_prenoms.prenom_3
  end

  test "met à jour l'information à propos des possibilité de retour siecle" do
    etablissement = Fabricate(:etablissement, uai: "0752387M")
    Fabricate(:dossier_eleve, identifiant: "070832327JA", ville_naiss: "blu", commune_insee_naissance: nil)
    dossier_valide = Fabricate(:dossier_eleve_valide, etablissement: etablissement)
    dossier_invalide = Fabricate(:dossier_eleve, mef_destination: nil, etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)

    dossier_valide.reload
    assert_equal "", dossier_valide.retour_siecle_impossible
    dossier_invalide.reload
    assert_equal I18n.t("retour_siecles.dossier_non_valide"), dossier_invalide.retour_siecle_impossible
  end

  test "quand il y deux structures, on ne prend que la premier (la deuxième correspond au groupe)" do
    etablissement = Fabricate(:etablissement, uai: "0660864F")

    dossier_valide = Fabricate(:dossier_eleve_valide, etablissement: etablissement, division: nil, identifiant: "070876696HA")

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_avec_double_structure.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)

    dossier_valide.reload
    assert_equal "", dossier_valide.retour_siecle_impossible
    assert_equal "301", dossier_valide.division
  end

  test "n'importe pas un fichier avec le mauvais UAJ" do
    etablissement = Fabricate(:etablissement, uai: "0752387E")

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, identifiant: "070832327JA")

    ImportEleves.new.perform(tache)
    dossier_eleve.reload
    assert_nil dossier_eleve.prenom_2
  end

end
