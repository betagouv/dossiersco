# frozen_string_literal: true

require "test_helper"

class MefDestinationTest < ActiveSupport::TestCase

  test "retrouve le mef destination qui correspond au seul dossier" do
    etablissement = Fabricate(:etablissement)
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    mef_service = MefDestination.new(etablissement)
    assert_equal dossier.mef_destination, mef_service.mef_destination(dossier.mef_origine)
  end

  test "retrouve le mef destination qui correspond a plusieurs dossiers" do
    etablissement = Fabricate(:etablissement)
    mef_origine = Fabricate(:mef)
    mef_destination = Fabricate(:mef)
    2.times { Fabricate(:dossier_eleve, etablissement: etablissement, mef_destination: mef_destination, mef_origine: mef_origine) }

    mef_service = MefDestination.new(etablissement)
    assert_equal mef_destination, mef_service.mef_destination(mef_origine)
  end

  test "renvoie nil si plus d'un mef_destination" do
    etablissement = Fabricate(:etablissement)
    mef_origine = Fabricate(:mef)
    mef_destination = Fabricate(:mef)
    Fabricate(:dossier_eleve, etablissement: etablissement, mef_destination: mef_destination, mef_origine: mef_origine)
    Fabricate(:dossier_eleve, etablissement: etablissement, mef_origine: mef_origine)

    mef_service = MefDestination.new(etablissement)
    assert_nil mef_service.mef_destination(mef_origine)
  end

end
