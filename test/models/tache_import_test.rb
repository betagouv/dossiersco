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

end
