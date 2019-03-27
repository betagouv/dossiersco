require 'test_helper'

class AgentMailerTest < ActionMailer::TestCase

  test "succes import" do
    agent = Fabricate(:agent)
    stat = {truc: 12, bidule: "un truc"}
    email = AgentMailer.succes_import(agent.email, stat)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["equipe@dossiersco.fr"], email.from
    assert_equal [agent.email], email.to
    assert_equal ["equipe@dossiersco.fr"], email.reply_to

    assert_equal 'Import de votre base élève dans DossierSCO', email.subject

  end


  test "erreur import" do
    agent = Fabricate(:agent)
    email = AgentMailer.erreur_import(agent.email)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["equipe@dossiersco.fr"], email.from
    assert_equal [agent.email], email.to
    assert_equal ["equipe@dossiersco.fr"], email.reply_to

    assert_equal "L'import de votre base élève a échoué", email.subject
  end

  test "invite premier agent" do
    agent = Fabricate(:agent)
    email = AgentMailer.invite_premier_agent(agent)

    assert_emails 1 do
      email.deliver_now
    end


    assert_equal ["equipe@dossiersco.fr"], email.from
    assert_equal [agent.email], email.to
    assert_equal ["equipe@dossiersco.fr"], email.reply_to

    assert_equal 'Activez votre compte DossierSCO', email.subject
    # assert email.body.include?("activation")
    # assert email.body.include?(agent.jeton)
  end

  test "invite agent" do
    agent = Fabricate(:agent, jeton: "un-super-jeton")
    admin = Fabricate(:admin)
    email = AgentMailer.invite_agent(agent, admin)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["equipe@dossiersco.fr"], email.from
    assert_equal [agent.email], email.to
    assert_equal ["equipe@dossiersco.fr"], email.reply_to

    assert_equal 'Activez votre compte agent sur DossierSCO', email.subject

    # assert email.body.include?(admin.email)
    # assert email.body.include?("activation")
    # assert email.body.include?(agent.jeton)
  end

end
