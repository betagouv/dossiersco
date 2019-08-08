# frozen_string_literal: true

require "test_helper"

require "exception_plusieurs_responsables_legaux_trouve"

class ImportResponsablesTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "lève une exception s'il y a deux représentant légaux qui porte le même nom, prénom et date de naissance dans le même établissement" do
    etablissement = Fabricate(:etablissement)

    Fabricate(:resp_legal,
              prenom: "Marylene",
              nom: "ROCQUE",
              profession: 34,
              dossier_eleve: Fabricate(:dossier_eleve, etablissement: etablissement))
    Fabricate(:resp_legal,
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

end
