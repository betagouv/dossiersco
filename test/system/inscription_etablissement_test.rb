# frozen_string_literal: true

require 'test_helper'

class InscriptionEtablissementTest < ActionDispatch::IntegrationTest

  test 'Inscription simple' do
    visit '/'
    click_link 'Vous êtes agent en EPLE ?'
    click_link 'Inscrire mon établissement sur DossierSCO'
    fill_in 'Uai', with: '0780119F'
    click_button 'Inscrire l\'établissement'
    assert_selector 'div', text: 'Un mail a été envoyé à ce.0780119F@ac-versailles.fr'

    etablissement = Etablissement.find_by(uai: '0780119F')
    assert_equal '0780119F', etablissement.uai

    agent = Agent.find_by(etablissement: etablissement)
    visit "/configuration/agents/#{agent.id}/activation?jeton=#{agent.jeton}"

    assert_selector 'h1', text: 'Activation du compte ce.0780119F@ac-versailles.fr'
  end

end
