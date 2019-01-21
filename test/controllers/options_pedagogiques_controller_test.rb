require 'test_helper'

class OptionsPedagogiquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @option_pedagogique = Fabricate(:option_pedagogique)
  end

  test "should get index" do
    get options_pedagogiques_url
    assert_response :success
  end

  test "should get new" do
    get new_option_pedagogique_url
    assert_response :success
  end

  test "should create option_pedagogique" do
    assert_difference('OptionPedagogique.count') do
      post options_pedagogiques_url, params: { option_pedagogique: { nom: "maçonnerie"  } }
    end

    assert_redirected_to options_pedagogiques_url
  end

  test "should get edit" do
    get edit_option_pedagogique_url(@option_pedagogique)
    assert_response :success
  end

  test "should update option_pedagogique" do
    patch option_pedagogique_url(@option_pedagogique), params: { option_pedagogique: { nom: "couture" } }
    assert_redirected_to options_pedagogiques_url
  end

  test "should destroy option_pedagogique" do
    assert_difference('OptionPedagogique.count', -1) do
      delete option_pedagogique_url(@option_pedagogique)
    end

    assert_redirected_to options_pedagogiques_url
  end
end
