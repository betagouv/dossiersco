# frozen_string_literal: true

require "test_helper"

class ImporterAffelnetTest < ActionDispatch::IntegrationTest

  test "crée les dossiers élève attendus" do
    fichier_affelnet = fixture_file_upload("files/test_import_affelnet.xlsm")
    tache = Fabricate(:tache_import, type_fichier: "inscription", fichier: fichier_affelnet)

    assert_equal 0, DossierEleve.count

    ImporterAffelnet.new.importer_affelnet(tache)

    assert_equal 6, DossierEleve.count
    assert_equal 1, Eleve.where(nom: "VODOU").count
    assert_equal 1, Eleve.where(nom: "FERSEN").count

    assert_equal 1, Eleve.find_by(nom: "FERSEN").dossier_eleve.resp_legal.first.priorite
  end

end
