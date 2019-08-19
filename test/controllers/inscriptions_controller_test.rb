# frozen_string_literal: true

require "test_helper"

class InscriptionControllerTest < ActionDispatch::IntegrationTest

  test "un agent modifie le mef de destination d'un élève" do
    agent = Fabricate(:agent)
    identification_agent(agent)
    mef_a_modifier = Fabricate(:mef)
    nouveau_mef = Fabricate(:mef)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_a_modifier)

    patch modifier_mef_eleve_path(dossier_eleve),
          params: { dossier_eleve: { mef_destination_id: nouveau_mef.id } }

    dossier_eleve.reload

    assert_equal nouveau_mef, dossier_eleve.mef_destination
  end

  test "un agent modifie le mef d'origine d'un élève" do
    agent = Fabricate(:agent)
    identification_agent(agent)
    mef_a_modifier = Fabricate(:mef)
    nouveau_mef = Fabricate(:mef)
    dossier_eleve = Fabricate(:dossier_eleve, mef_origine: mef_a_modifier)

    patch modifier_mef_eleve_path(dossier_eleve),
          params: { dossier_eleve: { mef_origine_id: nouveau_mef.id } }

    dossier_eleve.reload

    assert_equal nouveau_mef, dossier_eleve.mef_origine
  end

  test "sans dossier, après identification d'un agent existant, redirection sur le module de configuration" do
    agent = Fabricate(:admin, password: "uberP4ss")
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }

    assert_redirected_to "/configuration"
    assert_equal agent.email, session[:agent_email]
  end

  test "affiche une erreur de mauvais mot de passe avec agent existant" do
    agent = Fabricate(:admin, password: "uberP4ss")
    post "/agent", params: { email: agent.email, mot_de_passe: "mauvais mot de passe" }

    assert_redirected_to "/agent"
    assert_equal "Ces informations ne correspondent pas à un agent enregistré", flash[:alert]
    assert_nil session[:agent_email]
  end

  test "avec des dossiers, après identification d'un agent existant, redirection sur la liste des dossiers" do
    etablissement = Fabricate(:etablissement)
    Fabricate(:dossier_eleve, etablissement: etablissement)
    agent = Fabricate(:admin, password: "uberP4ss", etablissement: etablissement)
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }

    assert_redirected_to "/agent/liste_des_eleves"
    assert_equal agent.email, session[:agent_email]
  end

  test "avec des dossiers d'un autre etablissement, redirection sur le module de configuration" do
    Fabricate(:dossier_eleve)
    etablissement = Fabricate(:etablissement)
    agent = Fabricate(:admin, password: "uberP4ss", etablissement: etablissement)
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }

    assert_redirected_to "/configuration"
    assert_equal agent.email, session[:agent_email]
  end

  test "La casse en saisi n'est pas un soucis pour se connecter" do
    agent = Fabricate(:admin, email: "ubber@laposte.net")
    post "/agent", params: { email: "uBbeR@lApOsTe.nEt", mot_de_passe: agent.password }
    assert_redirected_to "/configuration"
    assert_equal agent.email, session[:agent_email]
  end

  test "Si l'agent n'est pas admin, même sans dossier, on reste sur la liste des élèves" do
    agent = Fabricate(:agent, password: "uberP4ss")
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }

    assert_redirected_to "/agent/liste_des_eleves"
    assert_equal agent.email, session[:agent_email]
  end

  test "Un agent modifie un résponsable légal" do
    etablissement = Fabricate(:etablissement)
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    agent = Fabricate(:agent, etablissement: etablissement)
    resp_legal = Fabricate(:resp_legal, dossier_eleve: dossier)
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }
    params = { "dossier_eleve" => { "resp_legal_attributes" =>
                                    { "0" => { "lien_de_parente" => "MERE", "prenom" => "Aline", "nom" => "Test",
                                               "tel_personnel" => "", "tel_portable" => "0101010101", "tel_professionnel" => "",
                                               "email" => "test@hotmail.fr", "adresse" => "19 RUE DU COLONEL MOUTARDE",
                                               "code_postal" => "75017", "ville" => "PARIS", "ville_etrangere" => "",
                                               "pays" => "100", "id" => resp_legal.id } },
                                    "dossier_id" => dossier.id } }

    patch agent_update_eleve_path(dossier), params: params
    resp_legal.reload
    assert_equal "MERE", resp_legal.lien_de_parente
    assert_equal "Aline", resp_legal.prenom
    assert_equal "19 RUE DU COLONEL MOUTARDE", resp_legal.adresse
    assert_equal "0101010101", resp_legal.tel_portable
    assert_equal "100", resp_legal.pays
  end

  test "Un agent modifie un contact en cas d'urgence" do
    etablissement = Fabricate(:etablissement)
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    agent = Fabricate(:agent, etablissement: etablissement)
    contact_urgence = Fabricate(:contact_urgence, dossier_eleve: dossier)
    post "/agent", params: { email: agent.email, mot_de_passe: agent.password }
    params = { "dossier_eleve" => { "contact_urgence_attributes" =>
                                    { "lien_avec_eleve" => "voisin", "prenom" => "Dupont", "nom" => "Dupond",
                                      "tel_principal" => "010101", "tel_secondaire" => "020202",
                                      "id" => contact_urgence.id },
                                    "dossier_id" => dossier.id } }

    patch agent_update_eleve_path(dossier), params: params
    contact_urgence.reload
    assert_equal "voisin", contact_urgence.lien_avec_eleve
    assert_equal "Dupont", contact_urgence.prenom
    assert_equal "010101", contact_urgence.tel_principal
  end

end
