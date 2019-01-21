require 'test_helper'

class MefControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mef = Fabricate(:mef)
  end

  test "should get index" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get mef_index_url
    assert_response :success
  end

  test "should get new" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get new_mef_url
    assert_response :success
  end

  test "should create mef" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference('Mef.count') do
      post mef_index_url, params: { mef: { code: @mef.code, libelle: @mef.libelle } }
    end

    assert_redirected_to mef_index_url
  end

  test "should get edit" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get edit_mef_url(@mef)
    assert_response :success
  end

  test "should update mef" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    patch mef_url(@mef), params: { mef: { code: @mef.code, libelle: @mef.libelle } }
    assert_redirected_to mef_index_url
  end

  test "should destroy mef" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference('Mef.count', -1) do
      delete mef_url(@mef)
    end

    assert_redirected_to mef_index_url
  end
end
