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
    options_en_erreur = [Fabricate(:option_pedagogique, etablissement: etablissement, code_matiere_6: nil)]
    identification_agent(admin)

    get new_retour_siecle_path
    assert_response :success
    assert_equal options_en_erreur, assigns(:options_en_erreur)
    assert_template "manque_code_matiere"
  end

  test "affiche le nombre de dossiers (resp_legal et eleve)" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    representant = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, etablissement: etablissement, etat: DossierEleve::ETAT[:valide], eleve: eleve, resp_legal: [representant])

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
    Fabricate(:dossier_eleve, etablissement: etablissement, etat: DossierEleve::ETAT[:valide], eleve: eleve, resp_legal: [representant])
    Fabricate(:dossier_eleve, etablissement: etablissement)

    get new_retour_siecle_path, params: { liste_ine: eleve.identifiant }

    assert_response :success
    assert_not_nil assigns(:selection_dossiers)
    assert_equal 1, assigns(:selection_dossiers).count
    assert_template "new"
  end

  test "liste les dossiers sans mef destination qui ne pourront être importé dans siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier_sans_mef = Fabricate(:dossier_eleve, mef_destination: nil, etablissement: etablissement)
    Fabricate(:dossier_eleve, mef_destination: Fabricate(:mef, etablissement: etablissement), etablissement: etablissement)

    get new_retour_siecle_path

    assert_equal dossier_sans_mef.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.new.dossier_sans_mef_destination"), assigns(:dossiers_bloques).first.raison
  end

  test "liste les dossiers dont nous n'avons pas le bon code profession" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal, profession: "Retraité employé, ouvrier")
    dossier = Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [resp_legal], etablissement: etablissement)
    Fabricate(:dossier_eleve, mef_destination: Fabricate(:mef, etablissement: etablissement), etablissement: etablissement)

    get new_retour_siecle_path
    assert_equal dossier.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.new.probleme_de_profession"), assigns(:dossiers_bloques).first.raison
  end

  test "liste les dossiers dont nous ne retrouvons pas la commune insee" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    eleve_sans_commune_insee = Fabricate(:eleve, commune_insee_naissance: nil)
    dossier = Fabricate(:dossier_eleve, eleve: eleve_sans_commune_insee, etablissement: etablissement)

    get new_retour_siecle_path
    assert_equal dossier.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.new.probleme_de_commune_insee"), assigns(:dossiers_bloques).first.raison
  end

  test "exporte uniquement le dossier en état validé" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:valide], etablissement: etablissement)
    Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente_de_validation], etablissement: etablissement)

    get new_retour_siecle_path
    assert_equal 1, assigns(:dossiers).count
    assert_equal [dossier], assigns(:dossiers)
  end

end
