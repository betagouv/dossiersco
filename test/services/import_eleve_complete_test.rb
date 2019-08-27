# frozen_string_literal: true

require "test_helper"

class ImportEleveCompleteTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "avec le minimum, on récupère la date de naissance formaté et nil sur la nationalité et la ville_naiss" do
    importer = ImportEleveComplete.new
    donnees_eleve = { date_naiss: "12/03/2006" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    attendu = { date_naiss: "2006-03-12", ville_naiss: nil }
    assert_equal attendu, donnees_corrigees
  end

  test "utilise un code 100 pour le pays_naiss FRANCE" do
    importer = ImportEleveComplete.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "FRANCE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 100, donnees_corrigees[:pays_naiss]
  end

  test "utilise un code 100 pour le nationalite FRANCE" do
    importer = ImportEleveComplete.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "FRANCE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 100, donnees_corrigees[:nationalite]
  end

  test "utilise un code 415 pour le pays_naiss ARGENTINE" do
    importer = ImportEleveComplete.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "ARGENTINE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 415, donnees_corrigees[:pays_naiss]
  end

  test "avec le minimum, renvoie les infos sur l'ancienne adresse à nil" do
    importer = ImportEleveComplete.new
    donnees_representants = {}
    donnees_corrigees = importer.traiter_donnees_representant(donnees_representants)
    attendu = { adresse_ant: nil, ville_ant: nil, code_postal_ant: nil }
    assert_equal attendu, donnees_corrigees
  end

  test "importer les mefs" do
    assert_equal 0, Mef.count

    etablissement = Fabricate(:etablissement)
    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    importer = ImportEleveComplete.new
    importer.import_mef(fichier_xls, etablissement.id)

    assert_equal 2, Mef.count
  end

  test "importer les mefs crée le MEF CM2 s'il n'existe pas déjà" do
    assert_equal 0, Mef.count
    etablissement = Fabricate(:etablissement)
    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    importer = ImportEleveComplete.new
    importer.import_mef(fichier_xls, etablissement.id)

    assert_equal 2, Mef.count
    assert Mef.all.map(&:libelle).include?("CM2")
  end

  test "importer dossiers élève" do
    assert_equal 0, DossierEleve.count
    etablissement = Fabricate(:etablissement)
    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    importer = ImportEleveComplete.new
    importer.import_dossiers_eleve(fichier_xls, etablissement.id, "reinscription")
    assert_equal 2, DossierEleve.count
  end

  test "importe pas un dossier élève si l'inscription à commencé" do
    etablissement = Fabricate(:etablissement)
    eleve = Fabricate(:eleve, nom: "Fordt")
    mef = Fabricate(:mef, libelle: "4EME")
    Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente], etablissement: etablissement, eleve: eleve, mef_origine: mef)

    importer = ImportEleveComplete.new

    assert_equal 1, DossierEleve.count
    assert_equal 1, Eleve.count

    ligne = Array.new(34)
    ligne[9] = "18/05/1991"
    ligne[13] = nil
    ligne[33] = "4EME"
    ligne[11] = eleve.identifiant

    importer.import_ligne(etablissement, ligne, "reinscription")[:result]

    assert_equal 1, DossierEleve.count
    assert_equal 1, Eleve.count
    assert_equal "Fordt", Eleve.first.nom
  end

  test "n'importe pas les élève en 3eme" do
    etablissement = Fabricate(:etablissement)
    importer = ImportEleveComplete.new
    mef = Fabricate(:mef, libelle: "3EME")
    ligne = Array.new(34)
    ligne[9] = "18/05/1991"
    ligne[32] = mef.code
    ligne[33] = mef.libelle
    importer.import_ligne(etablissement.id, ligne, "reinscription")
    assert_empty DossierEleve.where(mef_origine: mef)
  end

  test "supprime les espaces des numéros de téléphone des représentants légaux" do
    etablissement = Fabricate(:etablissement)
    importer = ImportEleveComplete.new
    mef = Fabricate(:mef, libelle: "4EME")
    ligne = Array.new(34)
    ligne[9] = "18/05/1991"
    ligne[11] = "12345678901"
    ligne[32] = mef.code
    ligne[33] = mef.libelle
    ligne[102] = "11 22 33 44 55"
    ligne[104] = "11 22 33 44 55"
    importer.import_ligne(etablissement.id, ligne, "reinscription")
    assert_equal "1122334455", RespLegal.first.tel_personnel
    assert_equal "1122334455", RespLegal.first.tel_portable
  end

  test "On arrive à créer un MEF 3EME" do
    etablissement = Fabricate(:etablissement)
    importer = ImportEleveComplete.new
    ligne = Array.new(34)
    ligne[32] = "10310019110"
    ligne[33] = "3EME"
    importer.import_ligne_mef(etablissement.id, ligne)
    assert_equal 1, Mef.all.count
  end

  test "on accèdes aux statistiques" do
    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    tache = Fabricate(:tache_import, fichier: fichier_xls)
    importer = ImportEleveComplete.new
    importer.perform(tache)
    attendu = { portable: 100, email: 50, eleves: 2, eleves_non_importes: [] }
    assert_equal attendu, importer.statistiques
  end

end
