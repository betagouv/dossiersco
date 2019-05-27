# frozen_string_literal: true

require "test_helper"

class MotDePasseAgentControllerTest < ActionDispatch::IntegrationTest

  test "#new" do
    get new_mot_de_passe_agent_path
    assert_response :success
  end

  test "#update sur un email inexistant" do
    post new_mot_de_passe_agent_path, params: { email: "henri@ford.com" }
    assert_redirected_to "/agent"
  end

  test "#update sur un email existant" do
    Fabricate(:agent, email: "henri@ford.com")
    post new_mot_de_passe_agent_path, params: { email: "henri@ford.com" }
    assert_redirected_to "/agent"
  end

end
