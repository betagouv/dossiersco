# frozen_string_literal: true

require "test_helper"

class EtablissementsControllerTest < ActionDispatch::IntegrationTest

  test "Une personne inconnue crée un etablissement" do
    uai = "0720081X"
    request = "https://opencartecomptable.herokuapp.com/api/etablissements?code_uai=#{uai}"
    body_response = [{
      nom: "Lab110Bis",
      adresse: "54 rue de bellechasse",
      code_postal: "75007",
      commune: "Paris"
    }].to_json
    stub_request(:get, request).to_return(body: body_response)

    post configuration_etablissements_path, params: {
      etablissement: { uai: uai }
    }
    assert_redirected_to new_configuration_etablissement_path
    expected = "Un mail a été envoyé à ce.0720081x@ac-nantes.fr"
    assert_equal expected, flash[:notice]
  end

  test "relance un email de finalisation d'inscription agent" do
    ActionMailer::Base.deliveries = []

    etablissement = Fabricate(:etablissement)
    Fabricate(:agent, etablissement: etablissement, password: nil, jeton: "something")
    post configuration_etablissement_relance_invitation_agent_path(etablissement.id)

    assert_equal 1, ActionMailer::Base.deliveries.count
    ActionMailer::Base.deliveries = []
  end

end
