# frozen_string_literal: true

require "test_helper"

class ContacterFamilleTest < ActiveSupport::TestCase

  include ActionMailer::TestHelper

  test "ecrit un Message et envoie un email quand un email est trouvé" do
    ActionMailer::Base.deliveries = []
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com", tel_portable: nil, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    etablissement.update!(envoyer_aux_familles: true)

    contacter = ContacterFamille.new(dossier)

    assert_equal 0, ActionMailer::Base.deliveries.count
    message = "un message"
    contacter.envoyer(message, "henri@ford.com")

    assert Message.first.contenu.include?(message)
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "ajoute le code pays au numéro de telephone quand il n'y est pas" do
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com", tel_portable: nil, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    etablissement.update!(envoyer_aux_familles: true)

    contacter = ContacterFamille.new(dossier)

    assert_equal "33777777777", contacter.ajoute_code_pays("7777777777")
  end

  test "n'ajoute pas le code pays au numéro de telephone quand il y est deja" do
    resp_legal = Fabricate(:resp_legal, email: "henri@ford.com", tel_portable: nil, priorite: 1)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    etablissement = dossier.etablissement
    etablissement.update!(envoyer_aux_familles: true)

    contacter = ContacterFamille.new(dossier)

    assert_equal "33666666666", contacter.ajoute_code_pays("33666666666")
  end

  test "true avec corine@example.com" do
    dossier = Fabricate(:dossier_eleve)
    contacter = ContacterFamille.new(dossier)
    assert contacter.email?("corine@example.com")
  end

  test "false avec 5555555555" do
    dossier = Fabricate(:dossier_eleve)
    contacter = ContacterFamille.new(dossier)
    assert !contacter.email?("5555555555")
  end

end
