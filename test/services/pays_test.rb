# frozen_string_literal: true

require "test_helper"

class PaysTest < ActiveSupport::TestCase

  test "#a_partir_du_code 100, renvoie FRANCE" do
    pays = Pays.new
    assert_equal "FRANCE", pays.a_partir_du_code("100")
  end

  test "#a_partir_du_code avec un code vide, renvoie 'SANS PAYS'" do
    pays = Pays.new
    assert_equal "SANS PAYS", pays.a_partir_du_code("")
  end

  test "#a_partir_du_code avec un code nil, renvoie 'SANS PAYS'" do
    pays = Pays.new
    assert_equal "SANS PAYS", pays.a_partir_du_code(nil)
  end

end
