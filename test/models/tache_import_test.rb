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

end
