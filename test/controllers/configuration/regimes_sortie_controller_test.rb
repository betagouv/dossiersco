# frozen_string_literal: true

require "test_helper"

class RegimesSortieControllerTest < ActionDispatch::IntegrationTest

  setup do
    @regime = Fabricate(:regime_sortie)
  end

  test "should get index" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get configuration_campagnes_path
    assert_response :success
  end

  test "should get new" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get new_configuration_regime_sortie_url
    assert_response :success
  end

  test "should create regime_sortie" do
    admin = Fabricate(:admin)
    etablissement = Fabricate(:etablissement)
    identification_agent(admin)

    params = { regime_sortie: { nom: "nom de test", etablissement: etablissement } }
    assert_difference("RegimeSortie.count") do
      post configuration_regimes_sortie_path, params: params
    end

    assert_redirected_to configuration_campagnes_path
  end

  test "should get edit" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get edit_configuration_regime_sortie_url(@regime)
    assert_response :success
  end

  test "should update regime_sortie" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    patch configuration_regime_sortie_url(@regime), params: { regime_sortie: { nom: @regime.nom, description: @regime.description } }
    assert_redirected_to configuration_campagnes_path
  end

  test "should destroy regime_sortie" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    assert_difference("RegimeSortie.count", -1) do
      delete configuration_regime_sortie_url(@regime)
    end

    assert_redirected_to configuration_campagnes_path
  end

end
