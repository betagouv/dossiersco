# frozen_string_literal: true

require 'test_helper'

class SuiviControllerTest < ActionDispatch::IntegrationTest

  test "affiche aucune stats de suivi quand il n'y a pas d'établissement" do
    get suivi_url

    assert_response :success
    assert_equal 0, assigns(:suivi).pas_encore_connecte
    assert_equal 0, assigns(:suivi).eleves_importe
    assert_equal 0, assigns(:suivi).piece_attendue_configure
    assert_equal 0, assigns(:suivi).familles_connectes
  end

  test "un établissement connecté si un seul agent, avec jeton" do
    agent_pas_connecte = Fabricate(:agent, jeton: 'jeton')
    etablissement_pas_connecte = Fabricate(:etablissement, agent: [agent_pas_connecte])

    agent = Fabricate(:agent, jeton: nil)
    stef_pas_connecte = Fabricate(:agent, jeton: 'un autre jeton')
    yannick_pas_connecte = Fabricate(:agent, jeton: 'encore un jeton')
    etablissement = Fabricate(:etablissement, agent: [agent, stef_pas_connecte, yannick_pas_connecte])

    get suivi_url
    assert_equal 1, assigns(:suivi).pas_encore_connecte
  end


  test "un etablissement avec eleves importe si dossier_evele" do
    etablissement = Fabricate(:dossier_eleve).etablissement
    sans_dossier = Fabricate(:etablissement)

    get suivi_url
    assert_equal 1, assigns(:suivi).eleves_importe
  end

  test "un etablissement avec des pieces attendues configurée" do
    Fabricate(:piece_attendue)
    etablissement_sans_piece_configure = Fabricate(:etablissement)

    get suivi_url
    assert_equal 1, assigns(:suivi).piece_attendue_configure
  end

  test "un etablissement avec des familles connectes" do
    Fabricate(:dossier_eleve, etat: "connecté")
    etablissement_sans_piece_configure = Fabricate(:etablissement)

    get suivi_url
    assert_equal 1, assigns(:suivi).familles_connectes
  end


end

