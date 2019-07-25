# frozen_string_literal: true

require "test_helper"

class ImporterSiecleTraiterLesDonnéeesRepresentantTest < ActiveJob::TestCase

  test "avec le minimum, renvoie les infos sur l'ancienne adresse à nil" do
    importer = ImporterSiecle.new
    donnees_representants = {}
    donnees_corrigees = importer.traiter_donnees_representant(donnees_representants)
    attendu = { adresse_ant: nil, ville_ant: nil, code_postal_ant: nil }
    assert_equal attendu, donnees_corrigees
  end

end
