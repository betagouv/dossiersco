# frozen_string_literal: true

require 'test_helper'

class TacheImportsControllerTest < ActionDispatch::IntegrationTest
  include ::ActiveJob::TestHelper

  test 'Import d\'un fichier Siecle' do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload('files/test_import_siecle.xls')

    assert_enqueued_with(job: ImporterSiecle) do
      post tache_imports_path, params: { tache_import: { fichier: fichier_xls, job_klass: 'ImporterSiecle'} }
      assert_equal 'ImporterSiecle', TacheImport.last.job_klass
    end
  end

  test 'Import d\'un fichier Affelnet' do
    admin = Fabricate(:admin)
    identification_agent(admin)

    fichier_xls = fixture_file_upload('files/test_import_affelnet.xlsm')

    assert_enqueued_with(job: ImporterAffelnet) do
      post tache_imports_path, params: { tache_import: { fichier: fichier_xls, job_klass: 'ImporterAffelnet'} }
      assert_equal 'ImporterAffelnet', TacheImport.last.job_klass
    end
  end
end