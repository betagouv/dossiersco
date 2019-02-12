# frozen_string_literal: true

require 'test_helper'

class MefTest < ActiveSupport::TestCase
  test 'a un fabricant valide' do
    assert Fabricate.build(:mef).valid?
  end

  test 'invalide sans code' do
    assert Fabricate.build(:mef, code: '').invalid?
  end

  test 'invalide sans libellé' do
    assert Fabricate.build(:mef, libelle: '').invalid?
  end

  test 'apres le mef 6eme vient le mef 5eme' do
    mef_5 = Fabricate(:mef, libelle: '5EME')
    mef_6 = Fabricate(:mef, libelle: '6EME', etablissement: mef_5.etablissement)
    assert_equal(mef_5, Mef.niveau_superieur(mef_6))
  end
end
