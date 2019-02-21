# frozen_string_literal: true

require 'test_helper'

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test 'Un admin crée un agent qui a un établissement lié' do
    admin = Fabricate(:admin)
    etablissement = admin.etablissement
    identification_agent(admin)

    post configuration_agents_path, params: { agent: { email: 'test@test.fr' } }

    assert_equal 1, Agent.where(email: 'test@test.fr', etablissement_id: etablissement.id).count
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

  test 'Un agent peu accéder à son profil' do
    agent = Fabricate(:agent)

    identification_agent(agent)
    get edit_configuration_agent_path(agent)

    assert_response :success
  end

  test "Un agent ne peut pas acceder qu'à son compte en édition" do
    agent_un = Fabricate(:agent)
    agent_deux = Fabricate(:agent)
    identification_agent(agent_un)

    get edit_configuration_agent_path(agent_deux)

    assert_response :success
    assert_equal agent_un, assigns(:agent_connecté)
  end

  test 'Un agent modifie son profil' do
    agent = Fabricate(:agent)
    identification_agent(agent)

    put configuration_agent_path(agent), params: { agent: { prenom: 'Lucien' } }

    assert_redirected_to configuration_agents_path
    assert_equal 'Lucien', Agent.find(agent.id).prenom
  end

  test 'contient un agent_connecté' do
    agent = Fabricate(:agent, jeton: 'uber_jeton')

    get configuration_agent_activation_path(agent, jeton: 'uber_jeton')

    assert_equal agent, assigns(:agent_connecté)
  end


end
