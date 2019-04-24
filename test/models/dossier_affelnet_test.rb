# frozen_string_literal: true

require "test_helper"

class DosserAffelnetTest < ActiveSupport::TestCase

  test "a une fabrique valid" do
    assert Fabricate.build(:dossier_affelnet).valid?
  end

  test "invalid sans établissement" do
    assert Fabricate.build(:dossier_affelnet, etablissement: nil).invalid?
  end

end
