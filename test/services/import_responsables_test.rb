# frozen_string_literal: true

require "test_helper"

require "exception_plusieurs_responsables_legaux_trouve"

class ImportResponsablesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "change le code profession existant par celui du fichier" do
    etablissement = Fabricate(:etablissement)
    resp_legal = Fabricate(:resp_legal,
                           prenom: "Marylene",
                           nom: "ROCQUE",
                           profession: 10,
                           dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      resp_legal.reload
      assert_equal "85", resp_legal.profession
    end
  end

  test "lève une exception s'il y a deux représentant légaux qui porte le même nom, prénom et date de naissance dans le même établissement" do
    etablissement = Fabricate(:etablissement)

    resp_legal = Fabricate(:resp_legal,
                           prenom: "Marylene",
                           nom: "ROCQUE",
                           profession: 34,
                           dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    resp_legal = Fabricate(:resp_legal,
                           prenom: "Marylene",
                           nom: "ROCQUE",
                           profession: 10,
                           dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_raise ExceptionPlusieursResponsablesLegauxTrouve do
      ImportResponsables.new.perform(tache)
    end
  end

  test "lève une exception quand aucun responsable légal n'a été trouvé" do
    etablissement = Fabricate(:etablissement)

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_raise ExceptionAucunResponsableLegalTrouve do
      ImportResponsables.new.perform(tache)
    end
  end

  test "quand le profession de dossiersco est le code 73 et celui de SIECLE n'est pas dans les 70, alors on prend le numéro 74 (le premier de la nouvelle catégorie)" do
    etablissement = Fabricate(:etablissement)
    resp_legal = Fabricate(:resp_legal,
                           prenom: "Marylene",
                           nom: "ROCQUE",
                           profession: 73,
                           dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      resp_legal.reload
      assert_equal "74", resp_legal.profession
    end
  end

  test "quand le profession de dossiersco est le code 76 et celui de SIECLE n'est pas dans les 70, alors on prend le numéro 77 (le premier de la nouvelle catégorie)" do
    etablissement = Fabricate(:etablissement)
    resp_legal = Fabricate(:resp_legal,
                           prenom: "Marylene",
                           nom: "ROCQUE",
                           profession: 76,
                           dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))

    fichier_xml = fixture_file_upload("files/responsables_avec_adresses_simple.xml")
    tache = Fabricate(:tache_import, type_fichier: "responsables", fichier: fichier_xml, etablissement: etablissement)

    assert_nothing_raised do
      ImportResponsables.new.perform(tache)
      resp_legal.reload
      assert_equal "77", resp_legal.profession
    end
  end


end
