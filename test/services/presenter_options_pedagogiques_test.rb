# frozen_string_literal: true

require "test_helper"

class PresenterOptionsPedagogiquesTest < ActiveSupport::TestCase

  test "on recupere un tableau vide si il n'y a pas d'options" do
    dossier_eleve = Fabricate(:dossier_eleve)

    assert_equal [], PresenterOptionsPedagogiques.new(dossier_eleve).options
  end

  test "on récupere une option ouverte à l'inscription" do
    option = Fabricate(:option_pedagogique)
    mef = Fabricate(:mef, options_pedagogiques: [option])
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef)
    options = PresenterOptionsPedagogiques.new(dossier_eleve).options

    assert_equal [option], options
  end

  test "on ne récupere pas une option fermée à l'inscription" do
    mef_option = Fabricate(:mef_option_pedagogique, ouverte_inscription: false)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_option.mef)

    assert_equal [], PresenterOptionsPedagogiques.new(dossier_eleve).options
  end

  test "l'option est abandonnable et que l'élève l'avait l'année passée" do
    option = Fabricate(:option_pedagogique)
    mef = Fabricate(:mef, options_pedagogiques: [option])
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef)
    dossier_eleve.options_origines = { option.id.to_s => { "nom" => option.nom } }
    options = PresenterOptionsPedagogiques.new(dossier_eleve).options

    assert_equal [option], options
  end

  test "l'option est non abandonnable et que l'élève l'avait l'année passée" do
    mef_option = Fabricate(:mef_option_pedagogique, abandonnable: false)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_option.mef)
    dossier_eleve.options_origines = { mef_option.option_pedagogique.id.to_s => { "nom" => mef_option.option_pedagogique.nom } }
    options = PresenterOptionsPedagogiques.new(dossier_eleve).options

    assert_equal [mef_option.option_pedagogique], options
  end

end
