# frozen_string_literal: true

require "test_helper"

class OptionsPedagogiquesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @option_pedagogique = Fabricate(:option_pedagogique)
  end

  test "should get index" do
    admin = Fabricate(:admin)
    post agent_url, params: { email: admin.email, mot_de_passe: admin.password }
    follow_redirect!

    get configuration_options_pedagogiques_url
    assert_response :success
  end

  test "should get new" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get new_configuration_option_pedagogique_url
    assert_response :success
  end

  test "should create option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference("OptionPedagogique.count") do
      post configuration_options_pedagogiques_url, params: { option_pedagogique: { nom: "maçonnerie" } }
    end

    assert_redirected_to configuration_options_pedagogiques_url
  end

  test "should get edit" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get edit_configuration_option_pedagogique_url(@option_pedagogique)
    assert_response :success
  end

  test "should update option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

<<<<<<< HEAD
    patch configuration_option_pedagogique_url(@option_pedagogique), params: { option_pedagogique: { nom: 'couture' } }
    assert_redirected_to configuration_options_pedagogiques_url
=======
    params = { option_pedagogique: { nom: "couture" } }
    patch option_pedagogique_url(@option_pedagogique), params: params
    assert_redirected_to options_pedagogiques_url
>>>>>>> rectifie les tests de controlleur avec les nouvelles regles rubocop
  end

  test "should destroy option_pedagogique" do
    admin = Fabricate(:admin)
    identification_agent(admin)

<<<<<<< HEAD
    assert_difference('OptionPedagogique.count', -1) do
      delete configuration_option_pedagogique_url(@option_pedagogique)
=======
    assert_difference("OptionPedagogique.count", -1) do
      delete option_pedagogique_url(@option_pedagogique)
>>>>>>> rectifie les tests de controlleur avec les nouvelles regles rubocop
    end

    assert_redirected_to configuration_options_pedagogiques_url
  end

  test 'modifie une option en non abandonnable' do
    admin = Fabricate(:admin)
    identification_agent(admin)
    mef_option = Fabricate(:mef_option_pedagogique)

    post definie_abandonnabilite_configuration_options_pedagogiques_path, params: { abandonnable: false, mef_option_pedagogique_id: mef_option.id }

    assert_equal false, MefOptionPedagogique.find(mef_option.id).abandonnable
  end

end
