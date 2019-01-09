require 'test_helper'
require 'fixtures'
init

class InscriptionsControllerTest < ActionDispatch::IntegrationTest

  def test_entree_succes_agent
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    follow_redirect!
    assert response.body.include? 'Collège Germaine Tillion'
  end

  def test_entree_mauvais_mdp_agent
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'pierre'}
    follow_redirect!
    assert response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_entree_mauvais_identifiant_agent
    post '/agent', params: {identifiant: 'jacques', mot_de_passe: 'pierre'}
    follow_redirect!
    assert response.body.include? 'Ces informations ne correspondent pas à un agent enregistré'
  end

  def test_nombre_dossiers_total
    post '/agent', params: {identifiant: 'pierre', mot_de_passe: 'demaulmont'}
    follow_redirect!
    doc = Nokogiri::HTML(response.body)
    selector = '#total_dossiers'
    affichage_total_dossiers = doc.css(selector).text
    assert_equal '5', affichage_total_dossiers
  end
end

