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

  test "retrouve une option existante à partir du code gestion et lui ajoute le code matière sur 6" do
    etablissement = Fabricate(:etablissement)
    option = Fabricate(:option_pedagogique, code_matiere_6: nil, code_matiere: "LCALA", etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportNomenclature.new.perform(tache)
      option.reload
      assert_equal "LCALA", option.code_matiere
      assert_equal "020300", option.code_matiere_6
    end
  end

  test "si une option de la nomenclature n'est pas trouvé, on crée une option" do
    etablissement = Fabricate(:etablissement)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    assert_equal 0, OptionPedagogique.count
    ImportNomenclature.new.perform(tache)
    assert_equal 1, OptionPedagogique.count
    option = OptionPedagogique.first
    assert_equal "LCA LATIN", option.nom
    assert_equal "LANGUES ET CULTURES DE L'ANTIQUITE LATIN", option.libelle
    assert_equal "LCALA", option.code_matiere
    assert_equal "020300", option.code_matiere_6
    assert_equal etablissement, option.etablissement
  end

  test "donne la priorité au code modalité O par rapport au S" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef, code: "20211010110", etablissement: etablissement)
    option = Fabricate(:option_pedagogique, code_matiere_6: "061300", etablissement: etablissement)
    mef_option = Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option, code_modalite_elect: nil)

    fichier_xml = fixture_file_upload("files/nomenclature_code_modalite_elec_double.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    ImportNomenclature.new.perform(tache)
    assert_equal "O", mef_option.reload.code_modalite_elect
  end

  test "récupère le CODE_MODALITE_ELECT dans le mef_option_pedagogique correspondant" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef, code: "10110001110", etablissement: etablissement)
    option = Fabricate(:option_pedagogique, code_matiere_6: "020300", etablissement: etablissement)
    mef_option = Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option, code_modalite_elect: nil)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    ImportNomenclature.new.perform(tache)
    assert_equal "F", mef_option.reload.code_modalite_elect
  end

  test "récupère le RANG_OPTION dans le mef_option_pedagogique correspondant" do
    etablissement = Fabricate(:etablissement)
    mef = Fabricate(:mef, code: "10110001110", etablissement: etablissement)
    option = Fabricate(:option_pedagogique, code_matiere_6: "020300", etablissement: etablissement)
    mef_option = Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option, code_modalite_elect: nil, rang_option: nil)

    fichier_xml = fixture_file_upload("files/nomenclature_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "nomenclature", fichier: fichier_xml, etablissement: etablissement)

    ImportNomenclature.new.perform(tache)
    assert_equal 1, mef_option.reload.rang_option
  end

end
