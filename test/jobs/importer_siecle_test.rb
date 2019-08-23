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

  test "appel ImportNomenclature si le type_fichier est 'nomenclature'" do
    ActionMailer::Base.deliveries.clear

    fichier_xls = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, fichier: fichier_xls, type_fichier: "nomenclature")

    ImporterSiecle.perform_now(tache.id, "an_email@example.com")

    assert_equal 1, ActionMailer::Base.deliveries.count
    last_email = ActionMailer::Base.deliveries.last
    assert_equal "Import de votre nomenclature dans DossierSCO", last_email.subject
  end

  test "appel ImportResponsables si le type_fichier est 'responsables'" do
    ActionMailer::Base.deliveries.clear

    fichier_xls = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, fichier: fichier_xls, type_fichier: "responsables")

    ImporterSiecle.perform_now(tache.id, "an_email@example.com")

    assert_equal 1, ActionMailer::Base.deliveries.count
    last_email = ActionMailer::Base.deliveries.last
    assert_equal "Import des responsables dans DossierSCO", last_email.subject
  end

  test "appel ImportEleves si le type_fichier est 'responsables'" do
    ActionMailer::Base.deliveries.clear

    fichier_xls = fixture_file_upload("files/eleves_avec_adresse_simple.xml")
    tache = Fabricate(:tache_import, fichier: fichier_xls, type_fichier: "eleves")

    ImporterSiecle.perform_now(tache.id, "an_email@example.com")

    assert_equal 1, ActionMailer::Base.deliveries.count
    last_email = ActionMailer::Base.deliveries.last
    assert_equal "Import des élèves dans DossierSCO", last_email.subject
  end

  test "appel ImportEleveComplete si le type_fichier est nil" do
    ActionMailer::Base.deliveries.clear

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    tache = Fabricate(:tache_import, fichier: fichier_xls, type_fichier: nil)

    ImporterSiecle.perform_now(tache.id, "an_email@example.com")

    assert_equal 1, ActionMailer::Base.deliveries.count
    last_email = ActionMailer::Base.deliveries.last
    assert_equal "Import de votre base élève dans DossierSCO", last_email.subject
  end



end
