# frozen_string_literal: true

require 'test_helper'
require 'fixtures'
init

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test 'Un admin crée un agent qui a un établissement lié' do
    admin = Fabricate(:admin)
    etablissement = Fabricate(:etablissement)
    identification_agent(admin)

    post configuration_agents_path, params: { agent: { identifiant: 'identifiant quelconque', password: 'password quelconque',
                                                       etablissement_id: etablissement.id, email: 'test@test.fr' } }

    assert_equal 1, Agent.where(identifiant: 'identifiant quelconque', etablissement_id: etablissement.id).count
  end

  test 'Un admin liste les agents de son établiseement' do
    agents = []
    agents << admin = Fabricate(:admin)
    3.times do
      agents << Fabricate(:agent, etablissement: admin.etablissement)
    end
    identification_agent(admin)

    get configuration_agents_path

    assert_response :success
    assert_equal [], agents - assigns(:agents)
  end

  test 'Un admin modifie un agent de son établissement' do
    admin = Fabricate(:admin)
    agent = Fabricate(:agent, etablissement: admin.etablissement, prenom: 'Jean')

    identification_agent(admin)
    put configuration_agent_path(agent), params: { agent: { prenom: 'Ibrahima' } }

    assert_redirected_to configuration_agents_path
    assert_equal Agent.find(agent.id).prenom, 'Ibrahima'
  end
end
