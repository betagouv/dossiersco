# frozen_string_literal: true

require "test_helper"

class ContactUrgenceTest < ActiveSupport::TestCase

  test "a une fabrique valide" do
    assert Fabricate.build(:contact_urgence).valid?
  end

  test "invalide sans nom" do
    assert Fabricate.build(:contact_urgence, nom: nil).invalid?
  end

  test "invalide sans au moins un telephone" do
    assert Fabricate.build(:contact_urgence, tel_principal: nil, tel_secondaire: nil).invalid?
    assert Fabricate.build(:contact_urgence, tel_principal: "0123456789", tel_secondaire: nil).valid?
    assert Fabricate.build(:contact_urgence, tel_principal: nil, tel_secondaire: "0123456789").valid?
  end

end
