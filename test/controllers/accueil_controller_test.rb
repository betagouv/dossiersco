# frozen_string_literal: true

require "test_helper"

class AccueilControllerTest < ActionDispatch::IntegrationTest

  def cree_dossier_eleve_et_identification
    eleve = Fabricate(:eleve)
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier_eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params_identification

    dossier_eleve
  end

  test "Sauvegarde un résponsable légal 1 sans responsable legal 2" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)

    params = { "dossier_eleve[resp_legal_attributes][0][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][0][prenom]": "Chahrazed",
               "dossier_eleve[resp_legal_attributes][0][nom]": "BELAMEIRI",
               "dossier_eleve[resp_legal_attributes][0][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][0][code_postal]": "75011",
               "dossier_eleve[resp_legal_attributes][0][ville]": "PARIS",
               "dossier_eleve[resp_legal_attributes][0][tel_personnel]": "09 80 57 67 38",
               "dossier_eleve[resp_legal_attributes][0][tel_portable]": "06 09 05 80 67",
               "dossier_eleve[resp_legal_attributes][0][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][0][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][0][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][0][enfants_a_charge]": "2",
               "dossier_eleve[resp_legal_attributes][0][communique_info_parents_eleves]": false }

    post famille_path, params: params

    assert_redirected_to administration_path
  end

  test "Sauvegarde un résponsable légal 2" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)
    dossier_eleve.resp_legal << Fabricate(:resp_legal, priorite: 2)

    params = { "dossier_eleve[resp_legal_attributes][0][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][0][prenom]": "Alexandre",
               "dossier_eleve[resp_legal_attributes][0][nom]": "Astier",
               "dossier_eleve[resp_legal_attributes][0][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][0][code_postal]": "75011",
               "dossier_eleve[resp_legal_attributes][0][ville]": "PARIS",
               "dossier_eleve[resp_legal_attributes][0][tel_personnel]": "09 80 57 67 38",
               "dossier_eleve[resp_legal_attributes][0][tel_portable]": "06 09 05 80 67",
               "dossier_eleve[resp_legal_attributes][0][pays]": "FRA",
               "dossier_eleve[resp_legal_attributes][0][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][0][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][0][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][0][enfants_a_charge]": "1",
               "dossier_eleve[resp_legal_attributes][0][communique_info_parents_eleves]": false,
               "dossier_eleve[resp_legal_attributes][0][ville_etrangere": "",
               "dossier_eleve[resp_legal_attributes][1][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][1][prenom]": "Chahrazed",
               "dossier_eleve[resp_legal_attributes][1][nom]": "BELAMEIRI", pays_rl2: "FRA",
               "dossier_eleve[resp_legal_attributes][1][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][1][code_postal]": "75011",
               "dossier_eleve[resp_legal_attributes][1][ville]": "PARIS",
               "dossier_eleve[resp_legal_attributes][1][tel_personnel]": "09 80 57 67 38",
               "dossier_eleve[resp_legal_attributes][1][tel_portable]": "06 09 05 80 67",
               "dossier_eleve[resp_legal_attributes][1][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][1][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][1][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][1][enfants_a_charge]": "2",
               "dossier_eleve[resp_legal_attributes][1][communique_info_parents_eleves]": false,
               "dossier_eleve[resp_legal_attributes][1][ville_etrangere]": "" }

    post famille_path, params: params

    assert_redirected_to administration_path
  end

  test "sauvegarde un responsable 1 vivant à l'étranger" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)

    params = { "dossier_eleve[resp_legal_attributes][0][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][0][prenom]": "Chahrazed",
               "dossier_eleve[resp_legal_attributes][0][nom]": "BELAMEIRI",
               "dossier_eleve[resp_legal_attributes][0][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][0][code_postal]": "",
               "dossier_eleve[resp_legal_attributes][0][ville]": "",
               "dossier_eleve[resp_legal_attributes][0][tel_personnel]": "09 80 57 67 38",
               "dossier_eleve[resp_legal_attributes][0][tel_portable]": "06 09 05 80 67",
               "dossier_eleve[resp_legal_attributes][0][pays]": "FIN",
               "dossier_eleve[resp_legal_attributes][0][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][0][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][0][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][0][enfants_a_charge]": "2",
               "dossier_eleve[resp_legal_attributes][0][communique_info_parents_eleves]": false,
               "dossier_eleve[resp_legal_attributes][0][ville_etrangere]": "Elsinki" }

    post famille_path, params: params

    responsable = RespLegal.find_by(email: "shehrazed31@hotmail.fr")

    assert_equal "Elsinki", responsable.ville
    assert_equal "FIN", responsable.pays
  end

  test "Ne sauvegarde pas un résponsable légal 1 sans téléphone" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)

    params = { "dossier_eleve[resp_legal_attributes][0][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][0][prenom]": "Chahrazed",
               "dossier_eleve[resp_legal_attributes][0][nom]": "BELAMEIRI",
               "dossier_eleve[resp_legal_attributes][0][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][0][code_postal]": "",
               "dossier_eleve[resp_legal_attributes][0][ville]": "",
               "dossier_eleve[resp_legal_attributes][0][tel_personnel]": "",
               "dossier_eleve[resp_legal_attributes][0][tel_portable]": "",
               "dossier_eleve[resp_legal_attributes][0][pays]": "FIN",
               "dossier_eleve[resp_legal_attributes][0][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][0][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][0][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][0][enfants_a_charge]": "2",
               "dossier_eleve[resp_legal_attributes][0][communique_info_parents_eleves]": false,
               "dossier_eleve[resp_legal_attributes][0][ville_etrangere]": "Elsinki" }

    post famille_path, params: params

    assert_response :success
  end

  test "Ne sauvegarde pas un résponsable légal 2 sans téléphone" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)
    resp = Fabricate(:resp_legal, priorite: 2)
    dossier_eleve.resp_legal << resp

    params = { "dossier_eleve[resp_legal_attributes][1][lien_de_parente]": "MERE",
               "dossier_eleve[resp_legal_attributes][1][id]": resp.id,
               "dossier_eleve[resp_legal_attributes][1][prenom]": "Chahrazed",
               "dossier_eleve[resp_legal_attributes][1][nom]": "BELAMEIRI",
               "dossier_eleve[resp_legal_attributes][1][adresse]": "37 avenue de la République",
               "dossier_eleve[resp_legal_attributes][1][code_postal]": "75011",
               "dossier_eleve[resp_legal_attributes][1][ville]": "PARIS",
               "dossier_eleve[resp_legal_attributes][1][tel_personnel]": "",
               "dossier_eleve[resp_legal_attributes][1][tel_portable]": "",
               "dossier_eleve[resp_legal_attributes][1][tel_professionnel]": "",
               "dossier_eleve[resp_legal_attributes][1][email]": "shehrazed31@hotmail.fr",
               "dossier_eleve[resp_legal_attributes][1][profession]": "artisan",
               "dossier_eleve[resp_legal_attributes][1][enfants_a_charge]": "2",
               "dossier_eleve[resp_legal_attributes][1][communique_info_parents_eleves]": false }

    post famille_path, params: params

    assert_response :success
  end

  test "Ne sauvegarde pas un résponsable légal 1 sans nom et prenom" do
    dossier_eleve = cree_dossier_eleve_et_identification

    resp_legal = Fabricate(:resp_legal)
    dossier_eleve.resp_legal << resp_legal

    params = { "dossier_eleve[resp_legal_attributes][0][nom]": "",
               "dossier_eleve[resp_legal_attributes][0][id]": resp_legal.id,
               "dossier_eleve[resp_legal_attributes][0][prenom]": "" }

    post famille_path, params: params

    assert_response :success
  end

end
