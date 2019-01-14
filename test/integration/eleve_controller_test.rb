require 'test_helper'

class EleveControllerTest < ActionDispatch::IntegrationTest

  def test_met_a_jour_les_options_demandees
    post '/identification', params: { identifiant: '6', annee: '1970', mois: '01', jour: '01'}
    post '/eleve', params: {"prenom"=>"Emile", "nom"=>"Blayo", "sexe"=>"Masculin", "ville_naiss"=>"Paris", "pays_naiss"=>"France", "nationalite"=>"FRANCE", "LV1"=>"allemand", "latin_present"=>"true", "grec_present"=>"true"}

    eleve = Eleve.find_by(identifiant: 6)
    assert_equal 4, eleve.montee.demandabilite.length
    assert_equal "allemand", eleve.demande.first.option.nom
    assert_equal "LV1", eleve.demande.first.option.groupe

    post '/eleve', params: {"prenom"=>"Emile", "nom"=>"Blayo", "sexe"=>"Masculin", "ville_naiss"=>"Paris", "pays_naiss"=>"France", "nationalite"=>"FRANCE", "LV1"=>"allemand", "latin_present"=>"true", "grec_present"=>"true"}

    eleve = Eleve.find_by(identifiant: 6)
    assert_equal 4, eleve.montee.demandabilite.length
    assert_equal "allemand", eleve.demande.first.option.nom
    assert_equal "LV1", eleve.demande.first.option.groupe

  end

end
