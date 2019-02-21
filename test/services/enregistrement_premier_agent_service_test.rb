require 'test_helper'

class EnregistrementPremierAgentServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'crée un établissement et un agent administrateur à partir d\'un uai' do
    assert_emails 1 do
      agent = EnregistrementPremierAgentService.new.execute('0753936w')
      assert_equal '0753936w', agent.etablissement.uai
      assert_equal 'ce.0753936w@ac-paris.fr', agent.email
      assert agent.admin?
    end
  end

  test 'avec un UAI du 78, l\'adresse est celle de l\'académie de Versailles' do
      service = EnregistrementPremierAgentService.new
      email = service.construit_email_chef_etablissement('0780119F')
      assert_equal 'ce.0780119F@ac-yvelines.fr', email
  end

  test 'avec un UAI du 75, l\'adresse est celle de l\'académie de Paris' do
      service = EnregistrementPremierAgentService.new
      email = service.construit_email_chef_etablissement('0753936w')
      assert_equal 'ce.0753936w@ac-paris.fr', email
  end
end
