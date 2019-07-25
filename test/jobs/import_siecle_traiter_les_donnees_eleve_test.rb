# frozen_string_literal: true

require "test_helper"

class ImporterSiecleTraiterLesDonnéeesEleveTest < ActiveJob::TestCase

  test "avec le minimum, on récupère la date de naissance formaté et nil sur la nationalité et la ville_naiss" do
    importer = ImporterSiecle.new
    donnees_eleve = { date_naiss: "12/03/2006" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    attendu = { date_naiss: "2006-03-12", ville_naiss: nil }
    assert_equal attendu, donnees_corrigees
  end

  test "utilise un code 100 pour le pays_naiss FRANCE" do
    importer = ImporterSiecle.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "FRANCE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 100, donnees_corrigees[:pays_naiss]
  end

  test "utilise un code 100 pour le nationalite FRANCE" do
    importer = ImporterSiecle.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "FRANCE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 100, donnees_corrigees[:nationalite]
  end

  test "utilise un code 415 pour le pays_naiss ARGENTINE" do
    importer = ImporterSiecle.new
    donnees_eleve = { date_naiss: "12/03/2006", pays_naiss: "ARGENTINE" }
    donnees_corrigees = importer.traiter_donnees_eleve(donnees_eleve)
    assert_equal 415, donnees_corrigees[:pays_naiss]
  end

end
