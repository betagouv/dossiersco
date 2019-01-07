require 'test_helper'
require 'fixtures'
init

class AccueilControllerTest < ActionDispatch::IntegrationTest
  def test_accueil
    get '/'
    assert response.parsed_body.include? 'Inscription'
  end

  def test_entree_succes_eleve_vierge
    e = Eleve.create! identifiant: 'XXX', date_naiss: '1915-12-19', nom: 'Piaf', prenom: 'Edit'
    DossierEleve.create! eleve_id: e.id, etablissement_id: Etablissement.first.id
    post '/identification', params: {identifiant: 'XXX ', annee: '1915', mois: '12', jour: '19'}
    follow_redirect!
    assert response.parsed_body.include? 'Pour réinscrire votre enfant'
  end

end
