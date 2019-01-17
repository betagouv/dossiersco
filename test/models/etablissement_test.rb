require 'test_helper'

class EtablissementTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valide
    assert Fabricate.build(:etablissement).valid?
  end

end

