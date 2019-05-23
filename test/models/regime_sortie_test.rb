# frozen_string_literal: true

require "test_helper"

class RegimeSortieTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:regime_sortie).valid?
  end

  test "un regime de sortie ne peut pas être supprimer si un dossier_eleve à selectionné ce régime" do
    regime = Fabricate(:regime_sortie)
    Fabricate(:dossier_eleve, regime_sortie: regime)

    assert_raise Exception do
      regime.destroy
    end
  end

  test "un regime de sortie connais le nombre de dossier lié" do
    regime = Fabricate(:regime_sortie)
    3.times { Fabricate(:dossier_eleve, regime_sortie: regime) }
    Fabricate(:dossier_eleve)

    assert_equal 3, regime.dossier_eleves.count
  end

end
