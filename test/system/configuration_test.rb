require 'test_helper'

class ConfigurationTest < ActionDispatch::IntegrationTest

  test "Configuration basique : ajout d'agent, import fichier siecle, modification option pédagogique" do
    admin = Fabricate(:admin)

    visit '/agent'
    assert_selector "h1", text: "Agent EPLE"

    fill_in 'identifiant', with: admin.identifiant
    fill_in 'mot_de_passe', with: admin.password
    click_button 'Connexion'

    assert_selector "h1", text: "Eleves en cours de traitement"

    click_link "Configuration"
    click_link "Agents"
  end
end
