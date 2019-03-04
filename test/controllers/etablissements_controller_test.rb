# frozen_string_literal: true

require 'test_helper'

class EtablissementsControllerTest < ActionDispatch::IntegrationTest
  test 'Une personne inconnue crée un etablissement' do
    post configuration_etablissements_path, params: { etablissement: { uai: '0720081X' } }
    assert_redirected_to new_configuration_etablissement_path
    assert_equal "Un mail a été envoyé à ce.0720081X@ac-nantes.fr", flash[:notice]
  end

  test 'Une personne inconnue souhaite créer un établissement existant' do
    skip
    assert_equal "Cet etablissement a déjà rejoint DossierSco", flash[:notice]
  end
end
