# frozen_string_literal: true

require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  def test_a_un_fabricant_valide
    assert Fabricate.build(:agent).valid?
    assert Fabricate.build(:admin).valid?
  end

  test "l'identifiant d'un agent est unique" do
    Fabricate(:agent, identifiant: 'Henri')
    assert Fabricate.build(:agent, identifiant: 'Henri').invalid?
  end

  test "l'identifiant d'un agent est unique peu importe la casse" do
    Fabricate(:agent, identifiant: 'henri')
    assert Fabricate.build(:agent, identifiant: 'Henri').invalid?
  end
end
