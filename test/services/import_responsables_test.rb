# frozen_string_literal: true

require "test_helper"

require "exception_plusieurs_responsables_legaux_trouve"

class ImportResponsablesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "ne met pas à jour deux représentants légaux qui portent le même nom et prénom dans le même établissement" do
    etablissement = Fabricate(:etablissement)

    premier_homonyme = Fabricate(:resp_legal,
                                 prenom: "Maryline",
                                 nom: "ROCK",
                                 profession: 34,
                                 paie_frais_scolaires: false,
                                 dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    second_homonyme = Fabricate(:resp_legal,
                                prenom: "Maryline",
                                nom: "ROCK",
                                profession: 10,
                                paie_frais_scolaires: false,
                                dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      assert_equal false, premier_homonyme.reload.paie_frais_scolaires
      assert_equal false, second_homonyme.reload.paie_frais_scolaires
    end
  end

  test "récupère l'information PAIE_FRAIS_SCOLAIRE pour chaque Resp_Legal" do
    etablissement = Fabricate(:etablissement)

    maryline = Fabricate(:resp_legal,
                         prenom: "Maryline",
                         nom: "ROCK",
                         profession: 34,
                         dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    truc = Fabricate(:resp_legal,
                     prenom: "Bidule",
                     nom: "TRUC",
                     profession: 34,
                     dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      assert maryline.reload.paie_frais_scolaires
      assert_equal false, truc.reload.paie_frais_scolaires
    end
  end

  test "affecte un code profession plus précis pour les retraités" do
    etablissement = Fabricate(:etablissement)

    maryline = Fabricate(:resp_legal,
                         prenom: "Maryline",
                         nom: "ROCK",
                         profession: 73,
                         dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    truc = Fabricate(:resp_legal,
                     prenom: "Bidule",
                     nom: "TRUC",
                     profession: 76,
                     dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      assert_equal "75",  maryline.reload.profession
      assert_equal "78",  truc.reload.profession
    end
  end

  test "conserve le code profession dossiersco des non-retraités" do
    etablissement = Fabricate(:etablissement)

    ada = Fabricate(:resp_legal,
                    prenom: "Ada",
                    nom: "LOVELACE",
                    profession: 40,
                    dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      assert_equal "40", ada.reload.profession
    end
  end

  test "ignore un responsable légal quand il n'est pas trouvé dans DossierSCO" do
    etablissement = Fabricate(:etablissement)

    truc = Fabricate(:resp_legal,
                     prenom: "Bidule",
                     nom: "TRUC",
                     profession: 12,
                     dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      assert_equal "12", truc.profession
      assert_equal 1, RespLegal.count
    end
  end

  test "met à jour l'information à propos des possibilité de retour siecle" do
    etablissement = Fabricate(:etablissement)
    dossier_valide = Fabricate(:dossier_eleve_valide, etablissement: etablissement)
    dossier_invalide = Fabricate(:dossier_eleve, mef_destination: nil, etablissement: etablissement)

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    ImportResponsables.new.perform(tache)

    dossier_valide.reload
    assert_equal "", dossier_valide.retour_siecle_impossible
    dossier_invalide.reload
    assert_equal I18n.t("retour_siecles.dossier_non_valide"), dossier_invalide.retour_siecle_impossible
  end

end
