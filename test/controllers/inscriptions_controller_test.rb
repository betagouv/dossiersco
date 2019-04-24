# frozen_string_literal: true

require "test_helper"

class InscriptionControllerTest < ActionDispatch::IntegrationTest

  test "un agent modifie le mef de destination d'un élève" do
    agent = Fabricate(:agent)
    identification_agent(agent)
    mef_a_modifier = Fabricate(:mef)
    nouveau_mef = Fabricate(:mef)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_a_modifier)

    patch modifier_mef_eleve_path(dossier_eleve),
          params: { dossier_eleve: { mef_destination_id: nouveau_mef.id } }

    dossier_eleve.reload

    assert_equal nouveau_mef, dossier_eleve.mef_destination
  end

  test "un agent modifie le mef d'origine d'un élève" do
    agent = Fabricate(:agent)
    identification_agent(agent)
    mef_a_modifier = Fabricate(:mef)
    nouveau_mef = Fabricate(:mef)
    dossier_eleve = Fabricate(:dossier_eleve, mef_origine: mef_a_modifier)

    patch modifier_mef_eleve_path(dossier_eleve),
          params: { dossier_eleve: { mef_origine_id: nouveau_mef.id } }

    dossier_eleve.reload

    assert_equal nouveau_mef, dossier_eleve.mef_origine
  end

end
