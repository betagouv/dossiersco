# frozen_string_literal: true

require "test_helper"

class ConvocationsControllerTest < ActionDispatch::IntegrationTest

  test "contient un établissement" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    etablissement = admin.etablissement

    get convocations_etablissement_url(etablissement)

    assert_response :success
    assert_equal etablissement, assigns(:etablissement)
  end

  test "liste_resp_legaux" do
    agent = Fabricate(:agent)
    dossier_eleve_non_connecte = Fabricate(:dossier_eleve,
                                           etablissement: agent.etablissement,
                                           etat: "pas connecté",
                                           resp_legal: [Fabricate(:resp_legal, priorite: 1)],
                                           eleve: Fabricate(:eleve, nom: "Piaf"))
    dossier_eleve_connecte = Fabricate(:dossier_eleve,
                                       etablissement: agent.etablissement,
                                       etat: "connecté",
                                       resp_legal: [Fabricate(:resp_legal, priorite: 1)],
                                       eleve: Fabricate(:eleve, nom: "Blayo"))

    identification_agent(agent)

    get convocations_etablissement_path(agent.etablissement)

    assert_response :success

    resp_legal_connecte = dossier_eleve_non_connecte.resp_legal.find { |d| d.priorite == 1 }
    resp_legal_non_connecte = dossier_eleve_connecte.resp_legal.find { |d| d.priorite == 1 }
    doc = Nokogiri::HTML(response.body)
    assert_equal resp_legal_connecte.prenom, doc.css("tbody > tr:nth-child(1) > td:nth-child(4)").text.strip
    assert_equal resp_legal_connecte.nom, doc.css("tbody > tr:nth-child(1) > td:nth-child(5)").text.strip
    assert_equal resp_legal_connecte.tel_personnel, doc.css("tbody > tr:nth-child(1) > td:nth-child(6)").text.strip
    assert_equal resp_legal_connecte.tel_portable, doc.css("tbody > tr:nth-child(1) > td:nth-child(7)").text.strip
    assert_equal resp_legal_non_connecte.prenom, doc.css("tbody > tr:nth-child(2) > td:nth-child(4)").text.strip
  end

end
