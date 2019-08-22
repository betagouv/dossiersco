# frozen_string_literal: true

require "test_helper"

class ImporterSiecleTest < ActiveJob::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "Une tache passe d'« en attente » à « en erreur » sans fichier" do
    tache = Fabricate(:tache_import)
    assert_equal "en attente", tache.statut
    ImporterSiecle.perform_now(tache.id, "an_email@example.com")
    tache.reload
    assert_equal "en erreur", tache.statut
  end

  test "Une tache passe d'« en attente » à « terminée » avec un fichier" do
    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    tache = Fabricate(:tache_import, fichier: fichier_xls)
    assert_equal "en attente", tache.statut
    ImporterSiecle.perform_now(tache.id, "an_email@example.com")
    tache.reload
    assert_equal "terminée", tache.statut
  end

  test "arrive à lire un zip" do
    fichier_zip = fixture_file_upload("files/nomenclature_simple.zip")
    tache = Fabricate(:tache_import, fichier: fichier_zip, type_fichier: "nomenclature")
    assert_equal "en attente", tache.statut
    ImporterSiecle.perform_now(tache.id, "an_email@example.com")
    tache.reload
    assert_equal "terminée", tache.statut
  end

  test "arrive à lire un non zippé" do
    fichier = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, fichier: fichier, type_fichier: "nomenclature")
    assert_equal "en attente", tache.statut
    ImporterSiecle.perform_now(tache.id, "an_email@example.com")
    tache.reload
    assert_equal "terminée", tache.statut
  end

end
