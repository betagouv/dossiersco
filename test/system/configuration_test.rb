# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < ActionDispatch::IntegrationTest

  include ::ActiveJob::TestHelper

  test "Configuration basique : un agent se connect, déclenche un import de fichier" do
    admin = Fabricate(:admin)
    visit "/agent/connexion"
    assert_selector "h1", text: "Agent EPLE"
    fill_in "email", with: admin.email
    fill_in "mot_de_passe", with: admin.password
    click_button "Se connecter"
    assert_selector "h3", text: "Dossiers Élèves"
    assert_selector "h3", text: "Campagne"

    click_link "Configuration"
    click_link "Import/export des élèves"
  end

end
