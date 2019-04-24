# frozen_string_literal: true

require "test_helper"

class DossierAffelnetControllerTest < ActionDispatch::IntegrationTest

  def test_upload_un_fichier_puis_affiche_un_compte_rendu_du_contenu
    admin = Fabricate(:admin)
    identification_agent(admin)

    file_name = "files/test_import_affelnet_4_lignes.xlsm"
    affelnet_xls = fixture_file_upload(file_name, "application/vnd.ms-excel")

    post dossier_affelnet_url, params: { fichier: affelnet_xls }

    assert_response :success
    assert_equal "test_import_affelnet_4_lignes.xlsm", assigns(:nom_fichier)
    assert_equal 4, assigns(:nombre_de_lignes)
  end

end
