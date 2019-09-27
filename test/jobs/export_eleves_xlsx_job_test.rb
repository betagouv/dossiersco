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
                   dossier.prenom,
                   dossier.nom,
                   "2004-04-27",
                   "FRANCE",
                   nil,
                   "75112",
                   "SANS NATIONALITE",
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
                 dossier.prenom,
                 dossier.nom,
                 "2004-04-27",
                 "FRANCE",
                 nil,
                 "75112",
                 "SANS NATIONALITE",
                 nil,
                 "",
                 "",
                 dossier.etat,
                 "X"]]
    assert_equal expected, export.faire_lignes(agent)
  end

  test "#cellules_entete " do
    agent = Fabricate(:agent)
    export = ExportElevesXlsxJob.new
    cellules_attendues = []
    cellules_attendues << "Classe actuelle"
    cellules_attendues << "MEF actuel"
    cellules_attendues << "Prenom"
    cellules_attendues << "Nom"
    cellules_attendues << "Date naissance"
    cellules_attendues << "Pays naissance"
    cellules_attendues << "Ville naissance"
    cellules_attendues << "Commune INSEE naissance"
    cellules_attendues << "Nationalite"
    cellules_attendues << "Sexe"
    cellules_attendues << "Autorise photo de classe"
    cellules_attendues << "Information médicale"
    cellules_attendues << "Status du dossier"
    cellules_attendues << "Demi-pensionnaire"

    2.times do
      cellules_attendues << "lien_de_parente"
      cellules_attendues << "prenom"
      cellules_attendues << "nom"
      cellules_attendues << "adresse"
      cellules_attendues << "code_postal"
      cellules_attendues << "ville"
      cellules_attendues << "pays"
      cellules_attendues << "ville_etrangere"
      cellules_attendues << "tel_personnel"
      cellules_attendues << "tel_portable"
      cellules_attendues << "tel_professionnel"
      cellules_attendues << "email"
      cellules_attendues << "profession"
      cellules_attendues << "enfants_a_charge"
      cellules_attendues << "communique_info_parents_eleves"
      cellules_attendues << "paie_frais_scolaires"
    end
    assert_equal cellules_attendues, export.cellules_entete(agent)
  end

  test "#cellules_infos_base" do
    dossier = Fabricate(:dossier_eleve)
    export = ExportElevesXlsxJob.new
    cellules_attendues = []
    cellules_attendues << nil
    cellules_attendues << dossier.mef_origine.libelle
    cellules_attendues << dossier.prenom
    cellules_attendues << dossier.nom
    cellules_attendues << "2004-04-27"
    cellules_attendues << "FRANCE"
    cellules_attendues << nil
    cellules_attendues << "75112"
    cellules_attendues << "SANS NATIONALITE"
    cellules_attendues << nil
    assert_equal cellules_attendues, export.cellules_infos_base(dossier)
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

  test "#faie_lignes utilise les infos nationalite, commune insee et ville_naissance" do
    agent = Fabricate(:agent)
    dossier = Fabricate(
      :dossier_eleve,
      etablissement: agent.etablissement,
      demi_pensionnaire: true,
      nationalite: "208",
      commune_insee_naissance: "75112",
      ville_naiss: "Paris",
      pays_naiss: "100"
    )
    export = ExportElevesXlsxJob.new
    expected = [[nil,
                 dossier.mef_origine.libelle,
                 dossier.prenom,
                 dossier.nom,
                 "2004-04-27",
                 "FRANCE",
                 "Paris",
                 "75112",
                 "TURQUE",
                 nil,
                 "",
                 "",
                 dossier.etat,
                 "X"]]
    assert_equal expected, export.faire_lignes(agent)
  end

  test "#cellules_resp_legaux renvoie des cases vide pour le 2eme resp si aucune info" do
    responsable = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve, resp_legal: [responsable])
    export = ExportElevesXlsxJob.new

    cellules_attendues = []
    cellules_attendues << responsable.lien_de_parente
    cellules_attendues << responsable.prenom
    cellules_attendues << responsable.nom
    cellules_attendues << responsable.adresse
    cellules_attendues << responsable.code_postal
    cellules_attendues << responsable.ville
    cellules_attendues << responsable.pays
    cellules_attendues << responsable.ville_etrangere
    cellules_attendues << responsable.tel_personnel
    cellules_attendues << responsable.tel_portable
    cellules_attendues << responsable.tel_professionnel
    cellules_attendues << responsable.email
    cellules_attendues << responsable.profession
    cellules_attendues << responsable.enfants_a_charge
    cellules_attendues << responsable.communique_info_parents_eleves
    cellules_attendues << responsable.paie_frais_scolaires

    assert_equal cellules_attendues, export.cellules_responsable_legaux(dossier)
  end

end
