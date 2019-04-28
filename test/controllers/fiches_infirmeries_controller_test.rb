# frozen_string_literal: true

require "test_helper"

class FichesInfirmeriesControllerTest < ActionDispatch::IntegrationTest

  test "contient un établissement" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    etablissement = admin.etablissement

    get fiches_infirmeries_etablissement_url(etablissement)

    assert_response :success
    assert_equal etablissement, assigns(:etablissement)
  end

end
