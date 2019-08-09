# frozen_string_literal: true

require "test_helper"

class CommuneTest < ActiveSupport::TestCase

  test "sans code postal, ne revoie un tableau vide" do
    commune = Commune.new
    assert_equal [], commune.code_postal("")
  end

  test "avec 78300, renvoie Poissy" do
    commune = Commune.new
    assert_equal ["POISSY"], commune.code_postal("78300")
  end

  test "avec 34567, renvoie un tableau vide " do
    commune = Commune.new
    assert_equal [], commune.code_postal("34567")
  end

  test "retrouve la ville de CERNY à partir du code insee 91129" do
    commune = Commune.new
    assert_equal "CERNY", commune.du_code_insee(91_129)
  end

end
