require 'test_helper'

class DossierEleveTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valid
    assert Fabricate.build(:dossier_eleve).valid?
  end

end

