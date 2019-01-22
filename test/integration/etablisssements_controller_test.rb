require 'test_helper'
require 'fixtures'
init

class EtablisssementsControllerTest < ActionDispatch::IntegrationTest
  test "Un admin crée un etablissement" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    post etablisssements_path, params: {etablissement: {nom: 'collège de la foresterie'}}

    assert_equal 1, Etablissement.where(nom: 'collège de la foresterie').count
  end
end
