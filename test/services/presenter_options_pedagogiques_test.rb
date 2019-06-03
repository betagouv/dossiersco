# frozen_string_literal: true

require "test_helper"

class PresenterOptionsPedagogiquesTest < ActiveSupport::TestCase

  test "on recupere un tableau vide si il n'y a pas d'options" do
    mef = Fabricate(:mef, options_pedagogiques: [])
    assert_equal [], PresenterOptionsPedagogiques.new(mef).options
  end

  test "avec un mef nil, renvoie un tableau vide" do
    assert_equal [], PresenterOptionsPedagogiques.new(nil).options
  end

  test "on récupere une option ouverte à l'inscription" do
    mef_option = Fabricate(:mef_option_pedagogique, ouverte_inscription: true)
    options = PresenterOptionsPedagogiques.new(mef_option.mef).options

    assert_equal [mef_option.option_pedagogique], options
  end

  test "on ne récupere pas une option fermée à l'inscription" do
    mef_option = Fabricate(:mef_option_pedagogique, ouverte_inscription: false)

    assert_equal [], PresenterOptionsPedagogiques.new(mef_option.mef).options
  end

end
