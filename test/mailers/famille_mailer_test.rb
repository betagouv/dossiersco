# frozen_string_literal: true

require "test_helper"

class FamilleMailerTest < ActionMailer::TestCase

  test "contacter_une_famille" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    agent = Fabricate(:agent, etablissement: etablissement)
    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com")
    Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement, resp_legal: [resp_legal])
    email = FamilleMailer.contacter_une_famille(eleve, agent, "un message spécifique")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [agent.email], email.from
    assert_equal [resp_legal.email, agent.email], email.to.sort
    assert_equal [agent.email].sort, email.reply_to.sort

    assert_equal "Réinscription de votre enfant au collège", email.subject

    assert email.body.include? etablissement.nom
    assert email.body.include? eleve.nom
    assert email.body.include?("un message spécifique")
  end

  test "envoyer mail confirmation" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true, email_reponse: "ce.1000135X@ac-truc.fr")
    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com")
    Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement, resp_legal: [resp_legal])

    email = FamilleMailer.envoyer_mail_confirmation(eleve)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["ce.1000135X@ac-truc.fr"], email.from
    assert_equal [resp_legal.email], email.to.sort
    assert_equal ["ce.1000135X@ac-truc.fr"].sort, email.reply_to.sort

    assert_equal "Réinscription de votre enfant au collège", email.subject

    assert email.body.include? etablissement.nom
    assert email.body.include? eleve.nom
  end

  test "mail validation inscription" do
    etablissement = Fabricate(:etablissement, envoyer_aux_familles: true)
    agent = Fabricate(:agent, etablissement: etablissement)
    eleve = Fabricate(:eleve)
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com")
    Fabricate(:dossier_eleve,
              eleve: eleve,
              etablissement: etablissement,
              resp_legal: [resp_legal])

    email = FamilleMailer.mail_validation_inscription(eleve, agent)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [agent.email], email.from
    assert_equal [resp_legal.email], email.to.sort
    assert_equal [agent.email].sort, email.reply_to.sort

    assert_equal "Réinscription de votre enfant au collège", email.subject

    assert email.body.include? etablissement.nom
    assert email.body.include? eleve.nom
  end

end
