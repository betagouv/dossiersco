# frozen_string_literal: true

require 'test_helper'
require 'fixtures'
init

class ConfigurationControllerTest < ActionDispatch::IntegrationTest
  def test_un_agent_non_admin_ne_peut_pas_acceder_a_la_configuration
    agent = Fabricate(:agent)
    identification_agent(agent)

    get configuration_url
    assert_redirected_to agent_tableau_de_bord_url
  end

  def test_un_admin_peut_acceder_a_la_configuration
    admin = Fabricate(:admin)
    identification_agent(admin)

    get configuration_url
    assert_response :success
  end
end
