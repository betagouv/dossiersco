require 'test_helper'

class ConfigurationTest < ActionDispatch::IntegrationTest
  include ::ActiveJob::TestHelper
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
    click_link text: "Créer un nouvel agent"

    attributs = Fabricate.attributes_for(:agent)
    fill_in "agent_identifiant", with: attributs[:identifiant]
    fill_in "agent_password", with: attributs[:password]
    click_button "valider"

    assert_selector "td", text: attributs[:identifiant]

    click_link "Suivi des inscriptions"
    click_link "Import"

    assert_selector "h2", text: "Import depuis siecle"

    attach_file("tache_import_fichier", Rails.root + "test/fixtures/files/test_import_siecle.xls")

    assert_equal 7, DossierEleve.count
    click_button "Importer le fichier SIECLE"
    assert_enqueued_jobs 1

    # assert_equal 9, DossierEleve.count
    #
    #
    # click_link "Configuration"
    # click_link "Options pédagogiques"
    # assert_selector "h1", text: "Options Pedagogiques"
    #
    # assert_selector "a", text: "Editer"
  end
end
