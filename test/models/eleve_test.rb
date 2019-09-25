# frozen_string_literal: true

require "test_helper"

class EleveTest < ActiveSupport::TestCase

  test "a un fabricant valid" do
    assert Fabricate.build(:eleve).valid?
  end

  test "#par_authentification" do
    eleve = Fabricate(:eleve)
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal eleve, Eleve.par_authentification(dossier.identifiant,
                                                   dossier.jour_de_naissance, dossier.mois_de_naissance, dossier.annee_de_naissance)

    eleve = Fabricate(:eleve, identifiant: "TRUC")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal eleve, Eleve.par_authentification("truc", dossier.jour_de_naissance, dossier.mois_de_naissance, dossier.annee_de_naissance)
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
