# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest

  test "On atterit sur l'index si pas connecté" do
    get "/"

    assert_response 200
  end

  test "On atterrit sur le dashboard agent si on est connecté en tant qu'agent" do
    agent = Fabricate(:agent)
    identification_agent(agent)

    get "/"

    assert_redirected_to agent_tableau_de_bord_path
  end

  test "On atterrit sur l'accueil famille si on est connecté en tant qu'élève" do
    etablissement = Fabricate(:etablissement)
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier.identifiant,
      annee: dossier.annee_de_naissance,
      mois: dossier.mois_de_naissance,
      jour: dossier.jour_de_naissance
    }
    post "/identification", params: params_identification

    assert_redirected_to accueil_path
  end

end
