require 'test_helper'

class EnregistrementPremierAgentServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "crée un établissement et un agent administrateur à partir d'un uai" do
    assert_emails 1 do
      agent = EnregistrementPremierAgentService.new.execute("0753936w")
      assert_equal "0753936w", agent.etablissement.uai
      assert_equal "ce.0753936w@ac-paris.fr", agent.email
      assert agent.admin?
    end
  end
end
