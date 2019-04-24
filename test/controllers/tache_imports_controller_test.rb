# frozen_string_literal: true

require "test_helper"

class TacheImportsControllerTest < ActionDispatch::IntegrationTest

  include ::ActiveJob::TestHelper

  test "Import d'un fichier Siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")

    assert_enqueued_with(job: ImporterSiecle) do
      params = { tache_import: { fichier: fichier_xls, job_klass: "ImporterSiecle" } }
      post tache_imports_path, params: params
      assert_equal "ImporterSiecle", TacheImport.last.job_klass
    end
  end

  test "Import d'un fichier Affelnet" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload("files/test_import_affelnet.xlsm")

    assert_enqueued_with(job: ImporterAffelnet) do
      params = { tache_import: { fichier: fichier_xls, job_klass: "ImporterAffelnet" } }
      post tache_imports_path, params: params
      assert_equal "ImporterAffelnet", TacheImport.last.job_klass
    end
  end

  test "Impossible d'importer un fichier Siecle si une tache est en cours de traitement" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)
    Fabricate(:tache_import_en_traitement, etablissement: etablissement)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    params = { tache_import: { fichier: fichier_xls, job_klass: "ImporterSiecle" } }
    post tache_imports_path, params: params

    assert_redirected_to new_tache_import_path
    assert_equal I18n.t("tache_imports.create.tache_deja_en_traitement"), flash[:alert]
  end

  test "Impossible d'importer un fichier Siecle si une tache est en attente" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)
    Fabricate(:tache_import_en_attente, etablissement: etablissement)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    params = { tache_import: { fichier: fichier_xls, job_klass: "ImporterSiecle" } }
    post tache_imports_path, params: params

    assert_redirected_to new_tache_import_path
    assert_equal I18n.t("tache_imports.create.tache_deja_en_traitement"), flash[:alert]
  end

  test "Affiche la page du formulaire" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get new_tache_import_path

    assert_response :success
  end

end
