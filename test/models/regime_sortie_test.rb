# frozen_string_literal: true

require "test_helper"

class RegimeSortieTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:regime_sortie).valid?
  end

end
