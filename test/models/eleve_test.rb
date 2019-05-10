# frozen_string_literal: true

require "test_helper"

class EleveTest < ActiveSupport::TestCase

  test "a un fabricant valid" do
    assert Fabricate.build(:eleve).valid?
  end

  test "a une année de naissance" do
    eleve = Fabricate.build(:eleve, date_naiss: "2004-04-27")
    assert_equal "2004", eleve.annee_de_naissance
  end

  test "a un mois de naissance" do
    eleve = Fabricate.build(:eleve, date_naiss: "2004-04-27")
    assert_equal "04", eleve.mois_de_naissance
  end

  test "a un jour de naissance" do
    eleve = Fabricate.build(:eleve, date_naiss: "2004-04-27")
    assert_equal "27", eleve.jour_de_naissance
  end

  test "#par_authentification" do
    eleve = Fabricate(:eleve)
    assert_equal eleve, Eleve.par_authentification(eleve.identifiant, eleve.jour_de_naissance, eleve.mois_de_naissance, eleve.annee_de_naissance)

    eleve = Fabricate(:eleve, identifiant: "TRUC")
    assert_equal eleve, Eleve.par_authentification("truc", eleve.jour_de_naissance, eleve.mois_de_naissance, eleve.annee_de_naissance)
  end

  test "#par_authentification avec des jour et mois sur 2 digits" do
    Fabricate(:eleve)
    eleve = Fabricate(:eleve, identifiant: "TRUC", date_naiss: "2006-12-23")
    assert_equal eleve, Eleve.par_authentification("truc", "23", "12", "2006")
  end

  test "#par_authentification avec des jour et mois sur 1 digits" do
    Fabricate(:eleve, identifiant: "TRUC")
    eleve = Fabricate(:eleve, identifiant: "TRUC", date_naiss: "2006-01-04")
    assert_equal eleve, Eleve.par_authentification("truc", "4", "1", "2006")
  end

end
