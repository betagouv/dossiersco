require 'test_helper'

class AgentTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valide
    assert Fabricate.build(:agent).valid?
    assert Fabricate.build(:admin).valid?
  end
end


