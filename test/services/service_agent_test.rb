# frozen_string_literal: true

require "test_helper"

class CommuneTest < ActiveSupport::TestCase

  test "reset mot_de_passe" do
    agent = Fabricate(:agent, email: "stf@lngs.net")
    service_agent = ServiceAgent.new(agent)
    assert service_agent.reset_mot_de_passe!
    agent.reload
    assert_not_nil agent.jeton
  end

end
