# frozen_string_literal: true

require "test_helper"

class ChangeContactUrgenceTest < ActiveSupport::TestCase

  test "sans paramètres, pas de changement du contact" do
    contact = Fabricate(:contact_urgence)
    dossier = Fabricate(:dossier_eleve)

    params = {}

    change = ChangeContactUrgence.new(dossier)
    change.applique(params)

    assert_equal contact, ContactUrgence.first
  end

end
