# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ActionDispatch::IntegrationTest
  include ::ActiveJob::TestHelper

  test "Configuration basique : un agent se connect, déclenche un import de fichier" do
    admin = Fabricate(:admin)
    visit '/agent'
    assert_selector 'h1', text: 'Agent EPLE'
    fill_in 'email', with: admin.email
    fill_in 'mot_de_passe', with: admin.password
    click_button 'Se connecter'
    assert_selector 'h1', text: 'Eleves en cours de traitement'

    click_link 'Configuration'
    click_link 'Import/export des élèves'
    within('.siecle') do
      assert_selector 'h3', text: 'Importer un fichier'
      choose 'SIECLE'
      attach_file('tache_import_fichier', Rails.root + 'test/fixtures/files/test_import_siecle.xls')
    end

    assert_equal 0, DossierEleve.count
    click_button 'Importer un fichier'
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
