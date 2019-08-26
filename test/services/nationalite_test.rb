# frozen_string_literal: true

require "test_helper"

class NationaliteTest < ActiveSupport::TestCase

  test "#a_partir_du_code 100, renvoie FRANCE" do
    nationalite = Nationalite.new
    assert_equal "FRANCAISE", nationalite.a_partir_du_code("100")
  end

  test "#a_partir_du_code avec un code vide, renvoie 'SANS NATIONALITE'" do
    nationalite = Nationalite.new
    assert_equal "SANS NATIONALITE", nationalite.a_partir_du_code("")
  end

  test "#a_partir_du_code avec un code nil, renvoie 'SANS NATIONALITE'" do
    nationalite = Nationalite.new
    assert_equal "SANS NATIONALITE", nationalite.a_partir_du_code(nil)
  end

end
