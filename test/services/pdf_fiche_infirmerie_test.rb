# frozen_string_literal: true

require "test_helper"

class PdfFicheInfirmerieTest < ActiveSupport::TestCase

  test "fonctionne" do
    dossier = Fabricate(:dossier_eleve, classe_ant: "5EME")
    etablissement = dossier.etablissement
    classe = dossier.classe_ant

    5.times do
      Fabricate(:dossier_eleve, etablissement: etablissement, classe_ant: classe)
    end

    fiche = PdfFicheInfirmerie.new(etablissement, classe, DossierEleve.all)
    assert_equal "5EME.pdf", fiche.nom
  end

end
