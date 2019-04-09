# frozen_string_literal: true

require 'test_helper'

class ExportsControllerTest < ActionDispatch::IntegrationTest

  test '#export-siecle' do
    admin = Fabricate(:admin)
    identification_agent(admin)

    3.times { Fabricate(:dossier_eleve, etablissement: admin.etablissement) }

    get export_siecle_configuration_exports_path

    assert_response :success

    fixture_file = "#{Rails.root}/test/fixtures/export_siecle.xml"
    File.open(fixture_file, "a+") do |f|
      f.puts(response.body)
    end

    xsd = Nokogiri::XML::Schema(File.read(Rails.root.join('doc/import_prive/schema_Import_3.0.xsd')))
    xml = Nokogiri::XML(response.body)
    assert_equal [], xsd.validate(xml)
    File.delete(fixture_file)
  end

  test '#export-options' do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get export_options_configuration_exports_path

    assert_response :success
  end


end
