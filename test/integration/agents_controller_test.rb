require 'test_helper'
require 'fixtures'
init

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "Un admin crée un agent qui a un établissement lié" do
    admin = Fabricate(:admin)
    etablissement = Fabricate(:etablissement)
    identification_agent(admin)

    post agents_path, params: {agent: {identifiant: 'identifiant quelconque', password: 'password quelconque',
                                       etablissement_id: etablissement.id}}

    assert_equal 1, Agent.where(identifiant: 'identifiant quelconque', etablissement_id: etablissement.id).count
  end
end
