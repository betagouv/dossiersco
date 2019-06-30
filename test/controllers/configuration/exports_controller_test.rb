# frozen_string_literal: true

require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest

  test "#export-siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal, email: "")
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal, email: nil)
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal, communique_info_parents_eleves: nil)
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal, profession: nil)
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])

    resp = Fabricate(:resp_legal, nom: nil)
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: admin.etablissement,
                              resp_legal: [resp])
    3.times do
      resp = Fabricate(:resp_legal, enfants_a_charge: nil)
      dossier_eleve = Fabricate(:dossier_eleve,
                                etablissement: admin.etablissement,
                                resp_legal: [resp])
      option = Fabricate(:option_pedagogique, nom: "un super nom d'option un peu long", obligatoire: "F", code_matiere: "ALGEV")
      dossier_eleve.options_pedagogiques << option
    end

    resp = Fabricate(:resp_legal, enfants_a_charge: 2)
    Fabricate(:dossier_eleve,
              mef_destination: nil,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    get export_siecle_configuration_exports_path

    assert_response :success

    schema = Rails.root.join("doc/import_prive/schema_Import_3.1.xsd")
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
  end

  test "L'adresse est renseignée dans l'export siècle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal,
                     adresse: "3 rue de test",
                     code_postal: "75000",
                     ville: "Ville de test",
                     pays: "FRA")
    Fabricate(:dossier_eleve,
              etablissement: admin.etablissement,
              resp_legal: [resp])
    %i[adresse code_postal ville pays].each do |partie_du_tag_adresse|
      resp_incomplet = Fabricate(:resp_legal,
                                 adresse: "adresse a ne pas afficher",
                                 code_postal: "75001",
                                 ville: "Ville a ne pas afficher",
                                 pays: "XXX")
      resp_incomplet[partie_du_tag_adresse] = nil
      Fabricate(:dossier_eleve,
                etablissement: admin.etablissement,
                resp_legal: [resp_incomplet])
    end

    get export_siecle_configuration_exports_path

    assert_response :success

    schema = Rails.root.join("doc/import_prive/schema_Import_3.1.xsd")
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
    assert_match "3 rue de test", response.body
    assert_match "75000", response.body
    assert_match "Ville de test", response.body
    assert_match "100", response.body
    assert_no_match "adresse a ne pas afficher", response.body
    assert_no_match "75001", response.body
    assert_no_match "Ville a ne pas afficher", response.body
    assert_no_match "XXX", response.body
  end

  test "export uniquement pour l'INE saisi" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal,
                     adresse: "3 rue de test",
                     code_postal: "75000",
                     ville: "Ville de test",
                     pays: "FRA")
    autre_resp = Fabricate(:resp_legal,
                           adresse: "8 rue de test",
                           code_postal: "75000",
                           ville: "Ville de test",
                           pays: "FRA")
    dossier = Fabricate(:dossier_eleve,
                        etablissement: admin.etablissement,
                        resp_legal: [resp])
    Fabricate(:dossier_eleve,
              etablissement: admin.etablissement,
              resp_legal: [autre_resp])

    get export_siecle_configuration_exports_path, params: { limite: true, liste_ine: dossier.eleve.identifiant }

    assert_response :success

    schema = Rails.root.join("doc/import_prive/schema_Import_3.1.xsd")
    Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)

    assert_equal 1, xml.xpath("//ELEVE").count
  end

end
