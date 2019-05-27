# frozen_string_literal: true

require "test_helper"

class AccueilControllerTest < ActionDispatch::IntegrationTest

  def cree_dossier_eleve_et_identification
    eleve = Fabricate(:eleve)
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement)
    params_identification = {
      identifiant: eleve.identifiant,
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

    params = { lien_de_parente_rl1: "MERE", prenom_rl1: "Chahrazed", nom_rl1: "BELAMEIRI",
               adresse_rl1: "37 avenue de la République", code_postal_rl1: "75011", ville_rl1: "PARIS",
               tel_personnel_rl1: "09 80 57 67 38", tel_portable_rl1: "06 09 05 80 67",
               tel_professionnel_rl1: "", email_rl1: "shehrazed31@hotmail.fr", profession_rl1: "artisan",
               enfants_a_charge_rl1: "2", communique_info_parents_eleves_rl1: false }

    post famille_path, params: params

    assert_redirected_to administration_path
  end

  test "Sauvegarde un résponsable légal 2" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)
    dossier_eleve.resp_legal << Fabricate(:resp_legal, priorite: 2)

    params = { lien_de_parente_rl2: "MERE", prenom_rl2: "Chahrazed", nom_rl2: "BELAMEIRI",
               adresse_rl2: "37 avenue de la République", code_postal_rl2: "75011", ville_rl2: "PARIS",
               tel_personnel_rl2: "09 80 57 67 38", tel_portable_rl2: "06 09 05 80 67",
               tel_professionnel_rl2: "", email_rl2: "shehrazed31@hotmail.fr", profession_rl2: "artisan",
               enfants_a_charge_rl2: "2", communique_info_parents_eleves_rl2: false }

    post famille_path, params: params

    assert_redirected_to administration_path
  end

  test "Ne sauvegarde pas un résponsable légal 1 sans téléphone" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)

    params = { tel_personnel_rl1: "", tel_portable_rl1: "" }

    post famille_path, params: params

    assert_redirected_to famille_path
  end

  test "Ne sauvegarde pas un résponsable légal 2 sans téléphone" do
    dossier_eleve = cree_dossier_eleve_et_identification

    dossier_eleve.resp_legal << Fabricate(:resp_legal)
    dossier_eleve.resp_legal << Fabricate(:resp_legal, priorite: 2)

    params = { lien_de_parente_rl2: "MERE", prenom_rl2: "Chahrazed", nom_rl2: "BELAMEIRI",
               adresse_rl2: "37 avenue de la République", code_postal_rl2: "75011", ville_rl2: "PARIS",
               tel_personnel_rl2: "", tel_portable_rl2: "",
               tel_professionnel_rl2: "", email_rl2: "shehrazed31@hotmail.fr", profession_rl2: "artisan",
               enfants_a_charge_rl2: "2", communique_info_parents_eleves_rl2: false }

    post famille_path, params: params

    assert_redirected_to famille_path
  end

  test "Ne sauvegarde pas un résponsable légal 1 sans nom et prenom" do
    dossier_eleve = cree_dossier_eleve_et_identification

    resp_legal = Fabricate(:resp_legal)
    dossier_eleve.resp_legal << resp_legal

    params = { nom_rl1: "", prenom_rl1: "" }

    post famille_path, params: params

    assert_redirected_to famille_path
  end

end
