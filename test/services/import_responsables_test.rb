# frozen_string_literal: true

require "test_helper"

require "exception_plusieurs_responsables_legaux_trouve"

class ImportResponsablesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "lève une exception s'il y a deux représentant légaux qui porte le même nom, prénom et date de naissance dans le même établissement" do
    etablissement = Fabricate(:etablissement)

    Fabricate(:resp_legal,
              prenom: "Maryline",
              nom: "ROCK",
              profession: 34,
              dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    Fabricate(:resp_legal,
              prenom: "Maryline",
              nom: "ROCK",
              profession: 10,
              dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_raise ExceptionPlusieursResponsablesLegauxTrouve do
      ImportResponsables.new.perform(tache)
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

  test "récupère le CODE_PROFESSION de chaque Resp_Legal" do
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

end
