# frozen_string_literal: true

require "test_helper"

class ImportNomenclatureTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "retrouve le mef correspondant au libelle, et y ajoute le code trouvé" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef, libelle: "5EME", etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportNomenclature.new.perform(tache)
      mef.reload
      assert_equal "10110001110", mef.code
    end
  end

  test "ne fait rien si le MEF n'est pas trouvé" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef, libelle: "4EME", code: "truc", etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportNomenclature.new.perform(tache)
      mef.reload
      assert_equal "truc", mef.code
    end
  end

  test "fonctionne sur plusieurs MEFs et un fichier plus gros" do
    etablissement = Fabricate(:etablissement)
    mef3 = Fabricate(:mef, libelle: "3EME", etablissement: etablissement)
    mef4 = Fabricate(:mef, libelle: "4EME", etablissement: etablissement)
    mef5 = Fabricate(:mef, libelle: "5EME", etablissement: etablissement)
    mef6 = Fabricate(:mef, libelle: "6EME", etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_tout_niveau.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportNomenclature.new.perform(tache)
      mef3.reload
      assert_equal "10310019110", mef3.code
      mef4.reload
      assert_equal "10210001110", mef4.code
      mef5.reload
      assert_equal "10110001110", mef5.code
      mef6.reload
      assert_equal "10010012110", mef6.code
    end
  end

  test "retrouve le mef de l'établissement, et correspondant au libelle, et y ajoute le code trouvé" do
    etablissement = Fabricate(:etablissement)
    autre_mef = Fabricate(:mef, libelle: "5EME", code: "truc")
    mef = Fabricate(:mef, libelle: "5EME", etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportNomenclature.new.perform(tache)
      mef.reload
      assert_equal "truc", autre_mef.code
      assert_equal "10110001110", mef.code
    end
  end

end
