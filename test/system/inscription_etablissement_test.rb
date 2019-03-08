# frozen_string_literal: true

require 'test_helper'

class InscriptionEtablissementTest < ActionDispatch::IntegrationTest

  test 'Inscription simple' do
    visit '/'
    click_link 'Vous êtes agent en EPLE ?'
    click_link 'Inscrire mon établissement sur DossierSCO'
    fill_in 'UAI', with: '0780119F'
    click_button "Envoyer la demande d'inscription"
    assert_selector 'div', text: 'Un mail a été envoyé à ce.0780119f@ac-versailles.fr'

    etablissement = Etablissement.find_by(uai: '0780119F')
    assert_equal '0780119F', etablissement.uai

    agent = Agent.find_by(etablissement: etablissement)
    visit "/configuration/agents/#{agent.id}/activation?jeton=#{agent.jeton}"

    assert_selector 'h1', text: 'Activation du compte ce.0780119f@ac-versailles.fr'
    fill_in 'agent_password', with: 'jaimelepoulet'
    click_button 'valider'

    assert_selector 'div', text: 'Votre compte a bien été créé'
    click_link 'Ajouter un agent'

    assert_selector 'h1', text: 'Ajouter un agent'
    fill_in 'agent_email', with: 'agent@email.fr'
    check 'agent_admin'
    click_button 'Ajouter'

    assert_selector 'td', text: 'agent@email.fr'
    assert_text 'Un email a été envoyé à l\'adresse agent@email.fr pour finaliser son inscription'

    visit "/agent/deconnexion"

    agent = Agent.find_by(email: 'agent@email.fr')
    visit "/configuration/agents/#{agent.id}/activation?jeton=#{agent.jeton}"

    assert_selector 'h1', text: 'Activation du compte agent@email.fr'
    fill_in 'agent_password', with: 'jemangequedeslegumes'
    click_button 'valider'

    assert_selector 'div', text: 'Votre compte a bien été créé'
    assert_selector 'a', text: 'Agents'
  end

  test 'inscription bloqué si un compte déjà créé avec cet UAI' do
    etablissement = Fabricate(:etablissement, uai: '0500079P')
    Fabricate(:agent, email: 'ce.0500079p@ac-paris.fr', etablissement: etablissement)

    assert_not_nil Etablissement.find_by(uai: '0500079P')
    assert_not_nil Agent.find_by(email: 'ce.0500079p@ac-paris.fr')

    visit '/'
    click_link 'Vous êtes agent en EPLE ?'
    click_link 'Inscrire mon établissement sur DossierSCO'
    fill_in 'UAI', with: '0500079P'
    click_button "Envoyer la demande d'inscription"
    assert_selector 'div', text: I18n.t('configuration.etablissements.create.uai_existant')
  end
end
