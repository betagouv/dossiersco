# frozen_string_literal: true

require "test_helper"

class OptionPedagogiqueTest < ActiveSupport::TestCase

  test "a une fabrique valide" do
    assert Fabricate.build(:option_pedagogique).valid?
  end

  test "sans mef, filtre_par renvoie un tableau vide" do
    assert_equal [], OptionPedagogique.filtre_par(nil)
  end

  test "filtre_par renvoie les options de ce mef" do
    mef = Fabricate(:mef)
    autre_mef = Fabricate(:mef)
    option_de_mef = Fabricate(:option_pedagogique, mef: [mef])
    Fabricate(:option_pedagogique, mef: [autre_mef])

    assert_equal [option_de_mef], OptionPedagogique.filtre_par(mef)
  end

end
