# frozen_string_literal: true

require "test_helper"

class ExportElevesXlsxJobTest < ActionDispatch::IntegrationTest

  test "#faie_lignes sans dossier, renvoie un tableau vide" do
    agent = Fabricate(:agent)
    export = ExportElevesXlsxJob.new
    assert_equal [], export.faire_lignes(agent)
  end

  test "#faie_lignes avec un dossier" do
    agent = Fabricate(:agent)
    dossier = Fabricate(:dossier_eleve, etablissement: agent.etablissement)
    export = ExportElevesXlsxJob.new
    assert_equal [[nil,
                   dossier.mef_origine.libelle,
                   dossier.eleve.prenom,
                   dossier.eleve.nom,
                   "2004-04-27",
                   nil,
                   "",
                   "",
                   dossier.etat,
                   ""]], export.faire_lignes(agent)
  end

  test "#faie_lignes avec un dossier demi-pensionnaire" do
    agent = Fabricate(:agent)
    dossier = Fabricate(:dossier_eleve, etablissement: agent.etablissement, demi_pensionnaire: true)
    export = ExportElevesXlsxJob.new
    expected = [[nil,
                 dossier.mef_origine.libelle,
                 dossier.eleve.prenom,
                 dossier.eleve.nom,
                 "2004-04-27", nil,
                 "",
                 "",
                 dossier.etat,
                 "X"]]
    assert_equal expected, export.faire_lignes(agent)
  end

  test "#cellules_entete " do
    agent = Fabricate(:agent)
    export = ExportElevesXlsxJob.new
    assert_equal ["Classe actuelle",
                  "MEF actuel",
                  "Prenom",
                  "Nom",
                  "Date naissance",
                  "Sexe",
                  "Autorise photo de classe",
                  "Information médicale",
                  "Status du dossier",
                  "Demi-pensionnaire"], export.cellules_entete(agent)
  end

  test "#cellules_infos_base" do
    dossier = Fabricate(:dossier_eleve)
    export = ExportElevesXlsxJob.new
    assert_equal [nil, dossier.mef_origine.libelle, dossier.eleve.prenom, dossier.eleve.nom, "2004-04-27", nil], export.cellules_infos_base(dossier)
  end

  test "#cellules_options_eleve quand l'élève n'a aucune options existantes" do
    dossier = Fabricate(:dossier_eleve)
    etablissement = dossier.etablissement
    2.times { etablissement.options_pedagogiques << Fabricate(:option_pedagogique) }
    export = ExportElevesXlsxJob.new
    assert_equal ["", ""], export.cellules_options_eleve(dossier)
  end

  test "#cellules_options_eleve quand l'élève a une options existantes" do
    dossier = Fabricate(:dossier_eleve)
    etablissement = dossier.etablissement
    2.times { etablissement.options_pedagogiques << Fabricate(:option_pedagogique) }
    dossier.options_pedagogiques << etablissement.options_pedagogiques.first
    export = ExportElevesXlsxJob.new
    assert_equal ["X", ""], export.cellules_options_eleve(dossier)
  end

  test "#cellules_regime_sortie quand l'élève n'a aucun régime de sortie proposé" do
    dossier = Fabricate(:dossier_eleve)
    etablissement = dossier.etablissement
    2.times { etablissement.regimes_sortie << Fabricate(:regime_sortie) }
    export = ExportElevesXlsxJob.new
    assert_equal ["", ""], export.cellules_regime_sortie(dossier)
  end

  test "#cellules_regime_sortie quand l'élève à un régime de sortie proposé" do
    dossier = Fabricate(:dossier_eleve)
    etablissement = dossier.etablissement
    2.times { etablissement.regimes_sortie << Fabricate(:regime_sortie) }
    dossier.regime_sortie = etablissement.regimes_sortie.first
    export = ExportElevesXlsxJob.new
    assert_equal ["X", ""], export.cellules_regime_sortie(dossier)
  end

  test "#cellules_pieces_jointes quand l'élève n'a pas la pièce attendue" do
    dossier = Fabricate(:dossier_eleve)
    etablissement = dossier.etablissement
    etablissement.pieces_attendues << Fabricate(:piece_attendue)
    export = ExportElevesXlsxJob.new
    assert_equal [""], export.cellules_pieces_jointes(dossier)
  end

end
