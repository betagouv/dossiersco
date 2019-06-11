# frozen_string_literal: true

require "test_helper"

class MefTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:mef).valid?
  end

  test "invalide sans libellé" do
    assert Fabricate.build(:mef, libelle: "").invalid?
  end

  test "apres le mef 6eme vient le mef 5eme" do
    mef5 = Fabricate(:mef, libelle: "5EME")
    mef6 = Fabricate(:mef, libelle: "6EME", etablissement: mef5.etablissement)
    assert_equal(mef5, Mef.niveau_superieur(mef6))
  end

  test "si le mef de destination n'existe pas renvoie un mef général" do
    mef5 = Fabricate(:mef, libelle: "5EME")
    Fabricate(:mef, libelle: "6EME", etablissement: mef5.etablissement)
    mef6s = Fabricate(:mef, libelle: "6EME SEGPA", etablissement: mef5.etablissement)

    assert_equal(mef5, Mef.niveau_superieur(mef6s))
  end

  test "#niveau_precedent de la 5eme est la 6eme" do
    mef5 = Fabricate(:mef, libelle: "5EME")
    mef6 = Fabricate(:mef, libelle: "6EME", etablissement: mef5.etablissement)
    assert_equal(mef6, Mef.niveau_precedent(mef5))
  end

  test "#niveau_precedent la 6eme est le CM2" do
    mef6 = Fabricate(:mef, libelle: "6EME")
    mef_cm2 = Fabricate(:mef, libelle: "CM2", etablissement: mef6.etablissement)
    assert_equal(mef_cm2, Mef.niveau_precedent(mef6))
  end

end
