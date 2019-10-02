# frozen_string_literal: true

require "test_helper"

class ExportListeChangementsXlsxJobTest < ActionDispatch::IntegrationTest

  test "#faie_lignes sans dossier, renvoie un tableau vide" do
    agent = Fabricate(:agent)
    export = ExportListeChangementsXlsxJob.new
    assert_equal [], export.faire_lignes(agent)
  end

  test "ligne" do
    resp_legal = Fabricate(:resp_legal, adresse: "1 rue Mozart\r\nMezidon-Cano", adresse_ant: "34 rue de l'église", email: "pere@laposte.net",
                                        tel_personnel: "0612345678", tel_portable: "0612345679", tel_professionnel: "0612345670")
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    export = ExportListeChangementsXlsxJob.new

    cellules_attendues = []
    cellules_attendues << dossier.nom
    cellules_attendues << dossier.prenom
    cellules_attendues << dossier.identifiant
    cellules_attendues << resp_legal.lien_de_parente
    cellules_attendues << resp_legal.nom
    cellules_attendues << resp_legal.prenom
    cellules_attendues << resp_legal.ligne1_adresse_siecle
    cellules_attendues << resp_legal.ligne2_adresse_siecle
    cellules_attendues << resp_legal.ligne3_adresse_siecle
    cellules_attendues << resp_legal.ligne4_adresse_siecle
    cellules_attendues << resp_legal.code_postal
    cellules_attendues << resp_legal.ville
    cellules_attendues << resp_legal.adresse_ant
    cellules_attendues << resp_legal.code_postal_ant
    cellules_attendues << resp_legal.ville_ant
    cellules_attendues << resp_legal.email
    cellules_attendues << resp_legal.tel_personnel
    cellules_attendues << resp_legal.tel_portable
    cellules_attendues << resp_legal.tel_professionnel

    assert_equal cellules_attendues, export.ligne(dossier)
  end

  test "faire lignes" do
    agent = Fabricate(:agent)
    export = ExportListeChangementsXlsxJob.new

    resp_legal = Fabricate(:resp_legal, adresse: "3 place de la gare", adresse_ant: "34 rue de l'église")
    Fabricate(:dossier_eleve, resp_legal: [resp_legal], etablissement: agent.etablissement)

    resp_legal_sans_changements = Fabricate(:resp_legal, adresse: "4 rue du pain")
    Fabricate(:dossier_eleve, resp_legal: [resp_legal_sans_changements], etablissement: agent.etablissement)

    assert_equal 1, export.faire_lignes(agent).count
  end

end
