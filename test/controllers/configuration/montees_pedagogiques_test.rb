# frozen_string_literal: true

require 'test_helper'

class MonteesPedagogiquesTest < ActionDispatch::IntegrationTest
  test 'Un agent créé une montée pédagogique' do
    admin = Fabricate(:admin)
    etablissement = admin.etablissement
    identification_agent(admin)
    mef_origin = Fabricate(:mef)
    mef_destination = Fabricate(:mef)
    option_pedagogique = Fabricate(:option_pedagogique)

    post configuration_montees_pedagogiques_path,
         params: { mef_origine: mef_origin.id, mef_destination: mef_destination.id,
                   "abandonnable-#{mef_destination.id}" => "1", option: option_pedagogique.id}

    assert_equal 1, MonteePedagogique.where(mef_origine: mef_origin, mef_destination: mef_destination,
                                            abandonnable: true, option_pedagogique: option_pedagogique, etablissement_id: etablissement.id).count
  end

  test 'Un agent supprime une montée pédagogiques' do
    admin = Fabricate(:admin)
    identification_agent(admin)
    montee_pedagogique = Fabricate(:montee_pedagogique)

    assert_difference('MonteePedagogique.count', -1) do
      delete configuration_montee_pedagogique_path(montee_pedagogique)
    end
  end
end
