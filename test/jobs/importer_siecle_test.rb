# frozen_string_literal: true

require 'test_helper'

class ImporterSiecleTest < ActiveJob::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "Une tache passe d'« en attente » à « en erreur » sans fichier" do
    tache = Fabricate(:tache_import)
    assert_equal 'en attente', tache.statut
    ImporterSiecle.perform_now(tache.id, 'an_email@example.com')
    tache.reload
    assert_equal 'en erreur', tache.statut
  end

  test "Une tache passe d'« en attente » à « terminée » avec un fichier" do
    fichier_xls = fixture_file_upload('files/test_import_siecle.xls')
    tache = Fabricate(:tache_import, fichier: fichier_xls)
    assert_equal 'en attente', tache.statut
    ImporterSiecle.perform_now(tache.id, 'an_email@example.com')
    tache.reload
    assert_equal 'terminée', tache.statut
  end

  test 'importer les mefs' do
    assert_equal 0, Mef.count

    etablissement = Fabricate(:etablissement)
    fichier_xls = fixture_file_upload('files/test_import_siecle.xls')
    importer = ImporterSiecle.new
    importer.import_mef(fichier_xls, etablissement.id)

    assert_equal 1, Mef.count
  end

  test 'importer dossiers élève' do
    assert_equal 0, DossierEleve.count
    etablissement = Fabricate(:etablissement)
    fichier_xls = fixture_file_upload('files/test_import_siecle.xls')
    importer = ImporterSiecle.new
    importer.import_dossiers_eleve(fichier_xls, etablissement.id)
    assert_equal 2, DossierEleve.count
  end

  test "n'importe pas les élève en 3eme" do
    etablissement = Fabricate(:etablissement)
    importer = ImporterSiecle.new
    mef = Fabricate(:mef, libelle: '3EME')
    ligne = Array.new(34)
    ligne[9] = '18/05/1991'
    ligne[32] = mef.code
    ligne[33] = mef.libelle
    importer.import_ligne(etablissement.id, ligne)
    assert_empty DossierEleve.where(mef_origine: mef)
  end

  test 'On arrive  à crééer un MEF 3EME' do
    etablissement = Fabricate(:etablissement)
    importer = ImporterSiecle.new
    ligne = Array.new(34)
    ligne[32] = '10310019110'
    ligne[33] = '3EME'
    importer.import_ligne_mef(etablissement.id, ligne)
    assert_equal 1, Mef.all.count
  end
end
