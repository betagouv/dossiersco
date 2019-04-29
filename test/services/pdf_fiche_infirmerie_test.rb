# frozen_string_literal: true

require "test_helper"

class PdfFicheInfirmerieTest < ActiveSupport::TestCase

  test "fonctionne" do
    eleve = Fabricate(:eleve, classe_ant: "5EME")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    etablissement = dossier.etablissement
    classe = dossier.eleve.classe_ant

    5.times do
      eleve = Fabricate(:eleve, classe_ant: classe)
      Fabricate(:dossier_eleve, eleve: eleve, etablissement: etablissement)
    end

    fiche = PdfFicheInfirmerie.new(etablissement, classe, DossierEleve.all)
    assert_equal "5EME.pdf", fiche.nom
  end

end
