# frozen_string_literal: true

require "test_helper"

class RetourSieclesControllerTest < ActionDispatch::IntegrationTest

  test "fonctionne avec un agent admin" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    get new_retour_siecle_path
    assert_redirected_to export_des_dossiers_retour_siecle_path
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
    assert_redirected_to manque_code_matiere_retour_siecle_path
    assert_equal options_en_erreur, assigns(:options_en_erreur)
  end

  test "Quand les élèves n'ont pas leur division, propose l'upload du fichier eleveavecadresse" do
    admin = Fabricate(:admin)
    etablissement = admin.etablissement
    dossier_eleve = Fabricate(:dossier_eleve, division: nil, etablissement: etablissement)

    identification_agent(admin)
    get new_retour_siecle_path
    assert_redirected_to manque_division_retour_siecle_path
    assert_equal [dossier_eleve], assigns(:dossiers_sans_division)
  end

  test "Quand les élèves n'ont pas leur division, propose de passer à la suite" do
    admin = Fabricate(:admin)
    etablissement = admin.etablissement
    dossier_eleve = Fabricate(:dossier_eleve, division: nil, etablissement: etablissement)

    identification_agent(admin)
    get export_des_dossiers_retour_siecle_path
    assert_response :success
    assert_equal [dossier_eleve], assigns(:dossiers_sans_division)
  end

  test "affiche le nombre de dossiers (resp_legal et eleve)" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    representant = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, etablissement: etablissement, etat: DossierEleve::ETAT[:valide], eleve: eleve, resp_legal: [representant])

    get export_des_dossiers_retour_siecle_path

    assert_not_nil assigns(:dossiers)
    assert_equal 1, assigns(:dossiers).count
  end

  test "avec un dossier seulement" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    representant = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, etablissement: etablissement, etat: DossierEleve::ETAT[:valide], eleve: eleve, resp_legal: [representant])
    Fabricate(:dossier_eleve, etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path, params: { liste_ine: eleve.identifiant }

    assert_response :success
    assert_not_nil assigns(:selection_dossiers)
    assert_equal 1, assigns(:selection_dossiers).count
  end

  test "liste les dossiers sans mef destination qui ne pourront être importé dans siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier_sans_mef = Fabricate(:dossier_eleve, mef_destination: nil, etablissement: etablissement)
    Fabricate(:dossier_eleve, mef_destination: Fabricate(:mef, etablissement: etablissement), etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path

    assert_equal dossier_sans_mef.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.dossier_sans_mef_destination"), assigns(:dossiers_bloques).first.raison
  end

  test "liste les dossiers dont nous n'avons pas le bon code profession" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal, profession: "Retraité employé, ouvrier")
    dossier = Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [resp_legal], etablissement: etablissement)
    Fabricate(:dossier_eleve, mef_destination: Fabricate(:mef, etablissement: etablissement), etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_equal dossier.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.probleme_de_profession"), assigns(:dossiers_bloques).first.raison
  end

  test "un dossier est non exportable si le pays de naissance est 100 (france) et qu'il n'y pas de commune insee" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    eleve_sans_commune_insee = Fabricate(:eleve, commune_insee_naissance: nil, pays_naiss: "100")
    dossier = Fabricate(:dossier_eleve, eleve: eleve_sans_commune_insee, etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_equal dossier.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.probleme_de_commune_insee"), assigns(:dossiers_bloques).first.raison
  end

  test "un dossier est exportable si le pays de naissance n'est pas 100 (france) et qu'il n'y pas de ville de naissance" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    eleve_sans_commune_insee = Fabricate(:eleve, ville_naiss: nil, pays_naiss: "216")
    Fabricate(:dossier_eleve, eleve: eleve_sans_commune_insee, etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_empty assigns(:dossiers_bloques)
  end

  test "liste les dossiers dont nous ne retrouvons pas le mef_an_dernier" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier_sans_mef_an_dernier = Fabricate(:dossier_eleve, mef_an_dernier: nil, etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_equal dossier_sans_mef_an_dernier.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.dossier_mef_an_dernier_inconnu"), assigns(:dossiers_bloques).first.raison
  end

  test "liste les dossiers avec un code mef_origine invalide" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef_non_conforme = Fabricate(:mef, code: "ACREER POUR BILANGUEALLEMAND")
    option = Fabricate(:option_pedagogique)
    Fabricate(:mef_option_pedagogique, mef: mef_non_conforme, option_pedagogique: option)
    dossier_avec_mef_non_conforme = Fabricate(:dossier_eleve_valide,
                                              etablissement: admin.etablissement,
                                              mef_origine: mef_non_conforme,
                                              options_pedagogiques: [option])

    get export_des_dossiers_retour_siecle_path
    assert_equal dossier_avec_mef_non_conforme.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.dossier_avec_mef_origine_invalide"), assigns(:dossiers_bloques).first.raison
  end

  test "liste les dossiers avec un code mef_destination invalide" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    mef_non_conforme = Fabricate(:mef, code: "ACREER POUR BILANGUEALLEMAND")
    option = Fabricate(:option_pedagogique)
    Fabricate(:mef_option_pedagogique, mef: mef_non_conforme, option_pedagogique: option)
    dossier_avec_mef_non_conforme = Fabricate(:dossier_eleve_valide,
                                              etablissement: admin.etablissement,
                                              mef_destination: mef_non_conforme,
                                              options_pedagogiques: [option])

    get export_des_dossiers_retour_siecle_path
    assert_equal dossier_avec_mef_non_conforme.eleve.identifiant, assigns(:dossiers_bloques).first.identifiant
    assert_equal I18n.t("retour_siecles.export_des_dossiers.dossier_avec_mef_destination_invalide"), assigns(:dossiers_bloques).first.raison
  end

  test "exporte uniquement le dossier en état validé" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:valide], etablissement: etablissement)
    Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente_de_validation], etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_equal 1, assigns(:dossiers).count
    assert_equal [dossier], assigns(:dossiers)
  end

  test "n'exporte pas un dossier sans mef_an_dernier" do
    admin = Fabricate(:admin)
    identification_agent(admin)
    etablissement = admin.etablissement

    dossier_ignore = Fabricate(:dossier_eleve, mef_an_dernier: nil,
                                               etat: DossierEleve::ETAT[:valide], etablissement: etablissement)

    dossier_pris_en_compte = Fabricate(:dossier_eleve, mef_an_dernier: Fabricate(:mef),
                                                       etat: DossierEleve::ETAT[:valide], etablissement: etablissement)

    get export_des_dossiers_retour_siecle_path
    assert_equal 1, assigns(:dossiers).count
    assert_not assigns(:dossiers).include?(dossier_ignore)
    assert_equal [dossier_pris_en_compte], assigns(:dossiers)
  end

end
