# frozen_string_literal: true

require "test_helper"

class PresenterOptionsPedagogiquesTest < ActiveSupport::TestCase

  test "on recupere un tableau vide si il n'y a pas d'options" do
    dossier_eleve = Fabricate(:dossier_eleve)

    assert_equal [], PresenterOptionsPedagogiques.new(dossier_eleve).options
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
