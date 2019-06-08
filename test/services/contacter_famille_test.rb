# frozen_string_literal: true

require "test_helper"

class ContacterFamilleTest < ActiveSupport::TestCase

  include ActionMailer::TestHelper

  test "ecrit un Message et envoie un email quand un email est trouvé" do
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com", tel_portable: nil, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    etablissement.update!(envoyer_aux_familles: true)

    contacter = ContacterFamille.new(dossier.eleve)

    assert_equal 0, ActionMailer::Base.deliveries.count
    message = "un message"
    contacter.envoyer(message, "henri@ford.com")

    assert Message.first.contenu.include?(message)
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

end
