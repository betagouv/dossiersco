require 'test_helper'

class OptionsPedagogiquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @option_pedagogique = Fabricate(:option_pedagogique)
  end

  test "should get index" do
    admin = Fabricate(:admin)
    post agent_url, params: {identifiant: admin.identifiant, mot_de_passe: admin.password}
    follow_redirect!

    get options_pedagogiques_url
    assert_response :success
  end

  test "should get new" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get new_option_pedagogique_url
    assert_response :success
  end

  test "should create option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference('OptionPedagogique.count') do
      post options_pedagogiques_url, params: { option_pedagogique: { nom: "maçonnerie"  } }
    end

    assert_redirected_to options_pedagogiques_url
  end

  test "should get edit" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get edit_option_pedagogique_url(@option_pedagogique)
    assert_response :success
  end

  test "should update option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    patch option_pedagogique_url(@option_pedagogique), params: { option_pedagogique: { nom: "couture" } }
    assert_redirected_to options_pedagogiques_url
  end

  test "should destroy option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference('OptionPedagogique.count', -1) do
      delete option_pedagogique_url(@option_pedagogique)
    end

    assert_redirected_to options_pedagogiques_url
  end
end
