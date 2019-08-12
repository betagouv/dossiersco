# frozen_string_literal: true

require "test_helper"

class ImportElevesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "enregistre les données élèves" do
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, identifiant: "070832327JA", ville_naiss: "blu", commune_insee_naissance: nil)
    dossier = Fabricate(:dossier_eleve, eleve: eleve)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportEleves.new.perform(tache)
      dossier.reload
      assert_equal "10210001110", dossier.mef_an_dernier
      assert_equal "4 D", dossier.division_an_dernier
      assert_equal "3 A", dossier.division
      eleve.reload
      assert_equal "93066", eleve.commune_insee_naissance
      assert_equal "ST DENIS", eleve.ville_naiss
    end
  end

  test "n'écrase pas les données présente" do
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, identifiant: "070832327JA", ville_naiss: "Saint Denis", commune_insee_naissance: "93066")
    Fabricate(:dossier_eleve, eleve: eleve)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportEleves.new.perform(tache)
      eleve.reload
      assert_equal "93066", eleve.commune_insee_naissance
      assert_equal "Saint Denis", eleve.ville_naiss
    end
  end

  test "récolte le ID_PRV_ELE du fichier avec l'élève" do
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, identifiant: "060375611AC", id_prv_ele: nil)
    autre_eleve = Fabricate(:eleve, identifiant: "070832327JA", id_prv_ele: nil)
    Fabricate(:dossier_eleve, eleve: eleve)

    fichier_xml = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "eleves", fichier: fichier_xml, etablissement: etablissement)

    ImportEleves.new.perform(tache)
    eleve.reload
    assert_equal "9065", eleve.id_prv_ele
    autre_eleve.reload
    assert_nil autre_eleve.id_prv_ele
  end

end
