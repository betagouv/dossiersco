# frozen_string_literal: true

require "test_helper"

class EleveTest < ActiveSupport::TestCase

  test "a un fabricant valid" do
    assert Fabricate.build(:eleve).valid?
  end

end
