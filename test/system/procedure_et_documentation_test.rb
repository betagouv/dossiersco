# frozen_string_literal: true

require "test_helper"

class ProcedureEtDocumentationTest < ActionDispatch::IntegrationTest

  include ::ActiveJob::TestHelper

  test "acc_s à la procédure de retour base élève" do
    visit "/"
    assert_selector "a", text: "Procédures de retour vers siecle"
    click_link "Procédures de retour vers siecle"

    assert_selector "h2", text: "Préparation"
    assert_selector "h2", text: "Retour Par ARENA Base Elève"
    assert_selector "p", text: "Complétez les éventuels codes matières manquant"
    assert_selector "p", text: "Sélectionnez le fichier ElevesAvecAdresses.xml"
    assert_selector "p", text: "Dézippez les trois fichiers ainsi sauvegardés"
  end

end
