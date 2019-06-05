# frozen_string_literal: true

require "test_helper"

class CampagnesControllerTest < ActionDispatch::IntegrationTest

  test "Modifie les informations de base d'une campagne" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)

    params = { etablissement: { date_limite: "3 juin", mot_accueil: "Bonjour", envoyer_aux_familles: "1" } }
    patch update_campagne_configuration_campagnes_path, params: params

    ets = Etablissement.find(etablissement.id)
    assert_equal "3 juin", ets.date_limite
    assert_equal "Bonjour", ets.mot_accueil
    assert_equal true, ets.envoyer_aux_familles
  end

  test "Modifie les informations de demi-pension" do
    etablissement = Fabricate(:etablissement)
    admin = Fabricate(:admin, etablissement: etablissement)
    identification_agent(admin)

    reglement = fixture_file_upload("files/sample.png", "image/png")

    params = { etablissement: { demande_caf: "1", reglement_demi_pension: reglement, gere_demi_pension: "1" } }
    patch update_campagne_configuration_campagnes_path, params: params

    ets = Etablissement.find(etablissement.id)
    assert_equal true, ets.demande_caf
    assert ets.reglement_demi_pension.present?
    assert_equal true, ets.gere_demi_pension
  end

end
