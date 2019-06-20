# frozen_string_literal: true

require "test_helper"

class SuiviControllerTest < ActionDispatch::IntegrationTest

  test "affiche aucune stats de suivi quand il n'y a pas d'établissement" do
    get suivi_index_url

    assert_response :success
    assert_equal [], assigns(:suivi).pas_encore_connecte
    assert_equal [], assigns(:suivi).eleves_importe
    assert_equal [], assigns(:suivi).familles_connectes
  end

  test "un établissement connecté même si plusieurs agents existent" do
    etablissement_pas_connecte = Fabricate(:etablissement)
    Fabricate(:agent, etablissement: etablissement_pas_connecte)

    autre_etablissement = Fabricate(:etablissement)
    3.times { Fabricate(:agent, etablissement: autre_etablissement) }

    assert_equal 2, Etablissement.all.count
    get suivi_index_url
    assert_equal [etablissement_pas_connecte, autre_etablissement].sort, assigns(:suivi).pas_encore_connecte.sort
  end

  test "un etablissement avec eleves importe si dossier_evele" do
    etablissement = Fabricate(:dossier_eleve).etablissement
    Fabricate(:etablissement)

    get suivi_index_url
    assert_equal [etablissement], assigns(:suivi).eleves_importe
  end

  test "un etablissement avec des familles connectes" do
    etablissement = Fabricate(:dossier_eleve, etat: "connecté").etablissement
    Fabricate(:etablissement)

    get suivi_index_url
    suivi_familles_connectees = [{ etablissement: etablissement, nb_familles_connectees: 1 }]
    assert_equal suivi_familles_connectees, assigns(:suivi).familles_connectes
  end

  test "un etablissement avec famille connectes n'est pas compté dans les établissements inscrits" do
    etablissement = Fabricate(:dossier_eleve, etat: "connecté").etablissement

    get suivi_index_url
    suivi_familles_connectees = [{ etablissement: etablissement, nb_familles_connectees: 1 }]
    assert_equal suivi_familles_connectees, assigns(:suivi).familles_connectes
    assert_equal [], assigns(:suivi).pas_encore_connecte
  end

end
