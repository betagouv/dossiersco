# frozen_string_literal: true

require "test_helper"

class AuthentificationCasEntControllerTest < ActionDispatch::IntegrationTest

  test "retour fichier XML" do
    etablissement = Fabricate(:etablissement, uai: "0751703U")
    resp_legal = Fabricate(:resp_legal,
                           nom: "FORD",
                           prenom: "Henri",
                           adresse: "533 RUE DU TEST",
                           email: "henri@ford.com")
    eleve = Fabricate(:eleve, prenom: "Mustang", nom: "FORD")
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: etablissement,
                              resp_legal: [resp_legal],
                              eleve: eleve)

    request = "https://ent.parisclassenumerique.fr/cas/serviceValidate?service=https://demo.dossiersco.fr/retour-ent&ticket=something"
    body_response = File.read(fixture_file_upload("files/retour_ent.xml"))

    stub_request(:get, request).to_return(body: body_response)

    get retour_ent_url, params: { ticket: "something" }

    assert_redirected_to "/#{dossier_eleve.etape_la_plus_avancee}"
  end

  test "pas de dossier correspondant" do
    request = "https://ent.parisclassenumerique.fr/cas/serviceValidate?service=https://demo.dossiersco.fr/retour-ent&ticket=something"
    body_response = File.read(fixture_file_upload("files/retour_ent.xml"))

    stub_request(:get, request).to_return(body: body_response)

    get retour_ent_url, params: { ticket: "something" }

    assert_redirected_to "/"
    assert_equal I18n.t(".dossier_non_trouver"), flash[:error]
  end

  test "avec plusieurs établissements correspondant" do
    etablissement = Fabricate(:etablissement, uai: "0751703U")
    resp_legal = Fabricate(:resp_legal,
                           nom: "FORD",
                           prenom: "Henri",
                           adresse: "533 RUE DU TEST",
                           email: "henri@ford.com")
    eleve = Fabricate(:eleve, prenom: "Mustang", nom: "FORD")
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: etablissement,
                              resp_legal: [resp_legal],
                              eleve: eleve)

    request = "https://ent.parisclassenumerique.fr/cas/serviceValidate?service=https://demo.dossiersco.fr/retour-ent&ticket=something"
    body_response = File.read(fixture_file_upload("files/retour_ent_plusieurs_etablissements.xml"))

    stub_request(:get, request).to_return(body: body_response)

    get retour_ent_url, params: { ticket: "something" }

    assert_redirected_to "/#{dossier_eleve.etape_la_plus_avancee}"
  end

  test "avec plusieurs dossier / responsable legal" do
    etablissement = Fabricate(:etablissement, uai: "0751703U")
    resp_legal = Fabricate(:resp_legal,
                           nom: "FORD",
                           prenom: "Henri",
                           adresse: "533 RUE DU TEST",
                           email: "henri@ford.com")

    eleve = Fabricate(:eleve, prenom: "Mustang", nom: "FORD")
    dossier_eleve = Fabricate(:dossier_eleve,
                              etablissement: etablissement,
                              resp_legal: [resp_legal],
                              eleve: eleve)

    resp_legal = Fabricate(:resp_legal,
                           nom: "FORD",
                           prenom: "Henri",
                           adresse: "533 RUE DU TEST",
                           email: "henri@ford.com")
    autre_eleve = Fabricate(:eleve, prenom: "Fiesta", nom: "FORD")
    autre_dossier_eleve = Fabricate(:dossier_eleve,
                                    etablissement: etablissement,
                                    resp_legal: [resp_legal],
                                    eleve: autre_eleve)

    request = "https://ent.parisclassenumerique.fr/cas/serviceValidate?service=https://demo.dossiersco.fr/retour-ent&ticket=something"
    body_response = File.read(fixture_file_upload("files/retour_ent_plusieurs_enfants.xml"))

    stub_request(:get, request).to_return(body: body_response)

    get retour_ent_url, params: { ticket: "something" }

    assert_response :success
    assert_template "authentification_cas_ent/choix_dossier_eleve", format: "html"
    assert response.body.include?(eleve.nom), "#{eleve.nom} devrait être dans l'écran"
    assert response.body.include?(eleve.prenom), "#{eleve.prenom} devrait être dans l'écran"
    assert response.body.include?(autre_eleve.nom), "#{autre_eleve.nom} devrait être dans l'écran"
    assert response.body.include?(autre_eleve.prenom), "#{autre_eleve.prenom} devrait être dans l'écran"
    assert response.body.include?(dossier_eleve.etablissement.nom), "#{dossier_eleve.etablissement.nom} devrait être dans l'écran"
    assert response.body.include?(autre_dossier_eleve.etablissement.nom), "#{autre_dossier_eleve.etablissement.nom} devrait être dans l'écran"
  end

  test "choix d'un dossier redirige vers le flow d'inscription de ce dossier" do
    etablissement = Fabricate(:etablissement, uai: "0751703U")
    resp_legal = Fabricate(:resp_legal,
                           nom: "FORD",
                           prenom: "Henri",
                           adresse: "533 RUE DU TEST",
                           email: "henri@ford.com")

    eleve = Fabricate(:eleve, prenom: "Mustang", nom: "FORD")
    Fabricate(:dossier_eleve,
              etablissement: etablissement,
              resp_legal: [resp_legal],
              derniere_etape: "confirmation",
              eleve: eleve)

    request = "https://ent.parisclassenumerique.fr/cas/serviceValidate?service=https%3A%2F%2Fdemo.dossiersco.fr%2Fretour-ent&ticket="
    body_response = File.read(fixture_file_upload("files/retour_ent_plusieurs_enfants.xml"))

    stub_request(:get, request).to_return(body: body_response)

    get choix_dossier_path, params: { resp_legal: resp_legal.id }

    assert_redirected_to "/confirmation"
  end

end
