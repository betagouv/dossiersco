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

end
