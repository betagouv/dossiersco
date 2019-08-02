# frozen_string_literal: true

require "test_helper"

class RetourSieclesControllerTest < ActionDispatch::IntegrationTest

  test "fonctionne avec un agent admin" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    get new_retour_siecle_path
    assert_response :success
  end

  test "redirige sur la page des non admin avec un agent non admin" do
    agent = Fabricate(:agent)
    identification_agent(agent)
    get new_retour_siecle_path
    assert_redirected_to "/agent/tableau_de_bord"
  end

  test "Quand les options n'ont pas de code, propose un lien pour aller uploader le fichier nomenclature" do
    admin = Fabricate(:admin)
    etablissement = admin.etablissement
    Fabricate(:option_pedagogique, etablissement: etablissement, code_matiere_6: nil)
    identification_agent(admin)

    get new_retour_siecle_path
    assert_response :success
    assert_template "manque_code_matiere"
  end

  test "affiche le nombre de dossiers (resp_legal et eleve)" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    representant = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, etablissement: etablissement, eleve: eleve, resp_legal: [representant])

    get new_retour_siecle_path

    assert_response :success
    assert_not_nil assigns(:dossiers)
    assert_equal 1, assigns(:dossiers).count
    assert_template "new"
  end

  test "avec un dossier seulement" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    representant = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, etablissement: etablissement, eleve: eleve, resp_legal: [representant])
    Fabricate(:dossier_eleve, etablissement: etablissement)

    get new_retour_siecle_path, params: { liste_ine: eleve.identifiant }

    assert_response :success
    assert_not_nil assigns(:selection_dossiers)
    assert_equal 1, assigns(:selection_dossiers).count
    assert_template "new"
  end

  test "liste les dossier sans mef destination qui ne pourront être exporté" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier_sans_mef = Fabricate(:dossier_eleve, mef_destination: nil, etablissement: etablissement)
    Fabricate(:dossier_eleve, mef_destination: Fabricate(:mef, etablissement: etablissement), etablissement: etablissement)

    get new_retour_siecle_path

    assert_equal [dossier_sans_mef], assigns(:dossiers_sans_mef_destination)
  end

end
