require 'test_helper'

class MefTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valide
    assert Fabricate.build(:mef).valid?
  end

end
