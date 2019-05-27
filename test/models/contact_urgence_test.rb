# frozen_string_literal: true

require "test_helper"

class ContactUrgenceTest < ActiveSupport::TestCase

  test "a une fabrique valide" do
    assert Fabricate.build(:contact_urgence).valid?
  end

  test "invalide sans nom si un tel est renseigner" do
    assert Fabricate.build(:contact_urgence, nom: nil, tel_principal: "0123456789").invalid?
    assert Fabricate.build(:contact_urgence, nom: nil, tel_secondaire: "0123456789").invalid?
  end

end
