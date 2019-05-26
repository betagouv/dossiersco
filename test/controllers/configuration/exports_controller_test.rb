# frozen_string_literal: true

require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest

  test "#export-siecle" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    resp = Fabricate(:resp_legal, email: "")
    Fabricate(:dossier_eleve,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    resp = Fabricate(:resp_legal, email: nil)
    Fabricate(:dossier_eleve,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    resp = Fabricate(:resp_legal, communique_info_parents_eleves: nil)
    Fabricate(:dossier_eleve,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    resp = Fabricate(:resp_legal, enfants_a_charge: 2)
    Fabricate(:dossier_eleve,
              mef_destination: nil,
              etablissement: admin.etablissement,
              resp_legal: [resp])

    get export_siecle_configuration_exports_path

    assert_response :success

    fixture_file = "#{Rails.root}/test/fixtures/export_siecle.xml"
    File.open(fixture_file, "a+") do |f|
      f.puts(response.body)
    end

    schema = Rails.root.join("doc/import_prive/schema_Import_3.1.xsd")
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
    File.delete(fixture_file)
  end

  test "#export-siecle lycée arago" do
    skip
    fixture_file = "#{Rails.root}/test/fixtures/files/export-siecle-arago-lycee.xml"

    schema = Rails.root.join("doc/import_prive/schema_Import_3.1.xsd")
    xsd = Nokogiri::XML::Schema(File.read(schema))
    xml = Nokogiri::XML(File.read(fixture_file))
    assert_equal [], xsd.validate(xml)
  end

end
