require 'test_helper'

class EnregistrementPremierAgentServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'crée un établissement et un agent administrateur à partir d\'un uai' do
    assert_emails 1 do
      agent = EnregistrementPremierAgentService.new.execute('0720081X')
      assert_equal '0720081X', agent.etablissement.uai
      assert_equal 'ce.0720081X@ac-nantes.fr', agent.email
      assert agent.admin?
    end
  end

  test "pas de création d'établissement si l'uai n'est pas valide" do
    assert_raise StandardError do
      EnregistrementPremierAgentService.new.execute('0753936y')
    end
  end

  test "blocage si l'uai est déjà enregistré" do
    Fabricate(:etablissement, uai: '7200727C')
    service = EnregistrementPremierAgentService.new
    assert_raise StandardError do
      EnregistrementPremierAgentService.new.execute('7200727C')
    end
  end

  test 'avec un UAI du 78, l\'adresse est celle de l\'académie de Versailles' do
      service = EnregistrementPremierAgentService.new
      email = service.construit_email_chef_etablissement('0780119F')
      assert_equal 'ce.0780119F@ac-versailles.fr', email
  end

  test 'avec un UAI du 75, l\'adresse est celle de l\'académie de Paris' do
      service = EnregistrementPremierAgentService.new
      email = service.construit_email_chef_etablissement('0753936w')
      assert_equal 'ce.0753936w@ac-paris.fr', email
  end

  test "l'uai 0753936w est valide" do
    service = EnregistrementPremierAgentService.new
    assert service.uai_valide?('0753936w')
  end

  test "l'uai 0572015F, avec une clef en majuscule, est valide" do
    service = EnregistrementPremierAgentService.new
    assert service.uai_valide?('0572015F')
  end

  test "l'uai 753936w n'est pas à la longueur 8" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('753936w')
  end

  test "l'uai 753936w n'a pas le bon format, le dernier caractère n'est pas une lettre clef" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('07539369')
  end

  test "la clef 'i' est interdite dans les uai" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('0753936i')
  end

  test "la clef 'o' est interdite dans les uai" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('0753936o')
  end

  test "la clef 'q' est interdite dans les uai" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('0753936q')
  end

  test "la clef 'p' n'est pas la bonne clef pour cet uai" do
    service = EnregistrementPremierAgentService.new
    assert ! service.uai_valide?('0753936p')
  end

  test "l'uai de la corse du sud a comme département 620" do
    service = EnregistrementPremierAgentService.new
    assert service.uai_valide?('6200006M')
  end

  test "l'uai de la haute corse a comme département 720" do
    service = EnregistrementPremierAgentService.new
    assert service.uai_valide?('7200727C')
  end

end
