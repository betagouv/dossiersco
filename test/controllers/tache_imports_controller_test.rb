# frozen_string_literal: true

require "test_helper"

class TacheImportsControllerTest < ActionDispatch::IntegrationTest

  include ::ActiveJob::TestHelper

  test "Import d'un fichier Siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")

    assert_enqueued_with(job: ImporterSiecle) do
      params = { tache_import: { fichier: fichier_xls, type_fichier: "reinscription" } }
      post tache_imports_path, params: params
      assert_equal "reinscription", TacheImport.last.type_fichier
    end
  end

  test "Import d'un fichier inscription" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload("files/test_import_6eme.xls")

    assert_enqueued_with(job: ImporterSiecle) do
      params = { tache_import: { fichier: fichier_xls, type_fichier: "inscription" } }
      post tache_imports_path, params: params
      assert_equal "inscription", TacheImport.last.type_fichier
    end
  end

  test "Impossible d'importer un fichier Siecle si une tache est en cours de traitement" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)
    Fabricate(:tache_import_en_traitement, etablissement: etablissement)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    params = { tache_import: { fichier: fichier_xls, type_siecle: "reinscription" } }
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

  test "redirige sur la page appelante" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)
    Fabricate(:tache_import_en_traitement, etablissement: etablissement)

    fichier_xls = fixture_file_upload("files/test_import_siecle.xls")
    params = { tache_import: { fichier: fichier_xls, type_siecle: "reinscription" } }

    page_origine = "/somewhere"
    post tache_imports_path, params: params, headers: { "HTTP_REFERER" => page_origine }

    assert_redirected_to page_origine
  end

end
