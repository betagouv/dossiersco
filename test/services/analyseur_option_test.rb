# frozen_string_literal: true

require "test_helper"

class AnalyseurOptionTest < ActiveSupport::TestCase

  test "#option_maintenue renvoie un tableau vide quand aucune options existe" do
    dossier = Fabricate.build(:dossier_eleve)
    analyseur = AnalyseurOption.new(dossier)
    assert_equal [], analyseur.option_maintenue
  end

  test "#option_maintenue renvoie l'option qui toujours selectionnée" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef)

    option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])
    options_origines = {}
    options_origines[option.id] = { nom: option.nom, code_matiere: option.code_matiere }

    dossier = Fabricate(:dossier_eleve,
                        mef_destination: mef,
                        etablissement: etablissement,
                        options_origines: options_origines,
                        options_pedagogiques: [option])

    analyseur = AnalyseurOption.new(dossier)
    assert_equal [option], analyseur.option_maintenue
  end

  test "#option_maintenue renvoie uniquement l'option qui toujours selectionnée" do
    options_origines = {}
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef)

    option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])
    options_origines[option.id] = { nom: option.nom, code_matiere: option.code_matiere }

    Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])
    options_origines[option.id] = { nom: option.nom, code_matiere: option.code_matiere }

    nouvelle_option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])

    dossier = Fabricate(:dossier_eleve,
                        mef_destination: mef,
                        etablissement: etablissement,
                        options_origines: options_origines,
                        options_pedagogiques: [option, nouvelle_option])

    analyseur = AnalyseurOption.new(dossier)
    assert_equal [option], analyseur.option_maintenue
  end

  test "#option_demandee renvoie un tableau vide quand aucune options existe" do
    dossier = Fabricate.build(:dossier_eleve)
    analyseur = AnalyseurOption.new(dossier)
    assert_equal [], analyseur.option_demandee
  end

  test "#option_demandee renvoie l'option nouvelle" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef)

    nouvelle_option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement, mef_destination: mef, options_pedagogiques: [nouvelle_option])

    analyseur = AnalyseurOption.new(dossier)
    assert_equal [nouvelle_option], analyseur.option_demandee
  end

  test "#option_demandee renvoie uniqueent l'option que l'élève ne suivait pas avant" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef)

    nouvelle_option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])
    option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])

    options_origines = {}
    options_origines[option.id] = { nom: option.nom, code_matiere: option.code_matiere }

    dossier = Fabricate(:dossier_eleve,
                        etablissement: etablissement,
                        mef_destination: mef,
                        options_pedagogiques: [nouvelle_option, option],
                        options_origines: options_origines)

    analyseur = AnalyseurOption.new(dossier)
    assert_equal [nouvelle_option], analyseur.option_demandee
  end

  test "#option_abandonnee renvoie un tableau vide quand aucune options existe" do
    Fabricate(:option_pedagogique)
    dossier = Fabricate.build(:dossier_eleve)
    analyseur = AnalyseurOption.new(dossier)
    assert_equal [], analyseur.option_abandonnee
  end

  test "#option_abandonnee renvoie l'option qui a été abandonnée" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef)

    option = Fabricate(:option_pedagogique, etablissement: etablissement, mef: [mef])

    options_origines = {}
    options_origines[option.id] = { nom: option.nom, code_matiere: option.code_matiere }

    dossier = Fabricate(:dossier_eleve,
                        etablissement: etablissement,
                        mef_destination: mef,
                        options_pedagogiques: [],
                        options_origines: options_origines)

    analyseur = AnalyseurOption.new(dossier)
    assert_equal [option], analyseur.option_abandonnee
  end

end
