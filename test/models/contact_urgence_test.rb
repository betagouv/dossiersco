# frozen_string_literal: true

require "test_helper"

class ContactUrgenceTest < ActiveSupport::TestCase

  test "à une fabrique valide" do
    assert Fabricate.build(:contact_urgence).valid?
  end

end
