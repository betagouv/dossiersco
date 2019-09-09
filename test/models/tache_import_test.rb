# frozen_string_literal: true

require "test_helper"

class TacheImportTest < ActiveSupport::TestCase

  test "a une fabrique valid" do
    assert Fabricate(:tache_import).valid?
  end

  test "#nomenclature? true si type_fichier est 'nomenclature'" do
    assert Fabricate(:tache_import, type_fichier: "nomenclature").import_nomenclature?
    assert !Fabricate(:tache_import, type_fichier: "siecle").import_nomenclature?
  end

  test "#responsables? true si type_fichier est 'responsables'" do
    assert Fabricate(:tache_import, type_fichier: "responsables").import_responsables?
    assert !Fabricate(:tache_import, type_fichier: "nomenclature").import_responsables?
  end

  test "#eleves? true si type_fichier est 'eleves'" do
    assert Fabricate(:tache_import, type_fichier: "eleves").import_eleves?
    assert !Fabricate(:tache_import, type_fichier: "nomenclature").import_eleves?
  end

  test "date_dernier_import_nomenclature renvoie nil si aucun import nomenclature n'a eu lieur" do
    etablissement = Fabricate(:etablissement)
    assert_nil TacheImport.date_dernier_import_nomenclature(etablissement)
  end

  test "date_dernier_import_nomenclature renvoie utilise le created_at comme date" do
    etablissement = Fabricate(:etablissement)
    ma_date = DateTime.new(2018, 4, 23, 11, 54)
    Fabricate(:tache_import, type_fichier: "nomenclature", created_at: ma_date, etablissement: etablissement)
    assert_equal ma_date, TacheImport.date_dernier_import_nomenclature(etablissement)
  end

  test "date_dernier_import_nomenclature renvoie la date created_at la plus récente comme date" do
    etablissement = Fabricate(:etablissement)
    date_recente = DateTime.new(2018, 4, 23, 11, 54)
    date_ancienne = DateTime.new(2015, 4, 23, 11, 54)

    Fabricate(:tache_import, type_fichier: "nomenclature", created_at: date_ancienne, etablissement: etablissement)
    Fabricate(:tache_import, type_fichier: "nomenclature", created_at: date_recente, etablissement: etablissement)

    assert_equal date_recente, TacheImport.date_dernier_import_nomenclature(etablissement)
  end

end
