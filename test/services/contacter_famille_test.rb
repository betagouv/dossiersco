# frozen_string_literal: true

require "test_helper"

class ContacterFamilleTest < ActiveSupport::TestCase

  include ActionMailer::TestHelper

  test "lève une exception quand pas d'email ou de portable trouvé" do
    resp_legal = Fabricate(:resp_legal, email: nil, tel_portable: nil)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    agent = Fabricate(:agent)

    assert_raise Exception do
      ContacterFamille.new(dossier, agent)
    end
  end

  test "ecrit un Message et envoie un email quand un email est trouvé" do
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com", tel_portable: nil, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    agent = Fabricate(:agent, etablissement: etablissement)
    etablissement.update!(envoyer_aux_familles: true)

    contacter = ContacterFamille.new(dossier, agent)
    assert_equal 0, ActionMailer::Base.deliveries.count
    message = "un message"
    contacter.envoyer(message)

    assert Message.first.contenu.include?(message)
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "écrit un Message si c'est un portable est trouvé" do
    resp_legal = Fabricate(:resp_legal, email: nil, tel_portable: "0123456789")
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    agent = Fabricate(:agent)

    contacter = ContacterFamille.new(dossier, agent)
    ActionMailer::Base.deliveries.clear
    message = "un message"

    contacter.envoyer(message)

    assert_equal 1, Message.count
    message_enregistre = Message.first
    assert message_enregistre.contenu.include?(message)
    assert_equal "en attente", message_enregistre.etat
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

end
