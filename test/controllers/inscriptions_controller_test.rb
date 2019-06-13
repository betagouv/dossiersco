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

end
