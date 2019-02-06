require 'test_helper'

class EtablissementsControllerTest < ActionDispatch::IntegrationTest
  test "Un admin crée un etablissement" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    post configuration_etablissements_path, params: {etablissement: {nom: 'collège de la foresterie', uai: "0753936w"}}

    assert_equal 1, Etablissement.where(nom: 'collège de la foresterie').count
  end
end
