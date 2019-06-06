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
    assert_equal I18n.t(".dossier_non_trouve"), flash[:alert]
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

  test "un cas qui pose problème" do
    etablissement = Fabricate(:etablissement, uai: "0751703U")
    resp_legal = Fabricate(:resp_legal,
                           nom: "DECLIC",
                           prenom: "Droit",
                           adresse: "20 RUE DU PARC")

    eleve = Fabricate(:eleve, prenom: "Gauche", nom: "DECLIC")
    Fabricate(:dossier_eleve,
              etablissement: etablissement,
              resp_legal: [resp_legal],
              derniere_etape: "confirmation",
              eleve: eleve)

    h = { "serviceResponse" => {
      "authenticationSuccess" => {
        "attributes" => {
          "userAttributes" => {
            "lastName" => "DECLIC",
            "country" => "FRANCE",
            "zipCode" => "75017",
            "city" => "PARIS",
            "displayName" => "DECLIC Droit",
            "children" => "[{\"displayName\":\"DECLIC Gauche\",\"externalId\":\"2992225\",\"id\":\"fe2AAAA0-e5e3-4fce-a8e4-e8fc572f0a47\"}]",
            "surname" => "DECLIC",
            "email" => { "xmlns" => "" },
            "address" => "20 RUE DU PARC",
            "mobile" => { "xmlns" => "" },
            "structureNodes" => "[{\"area\":\"01000$BASSIN PARIS\",\"zipCode\":\"75017\",\"address\":\"5 BIS RUE SAINT-FERDINAND\",\"city\":\"PARIS\",\"created\":\"2017-07-26T10:32:00.355+02:00\",\"contract\":\"PU\",\"externalId\":\"1814\",\"source\":\"AAF\",\"joinKey\":[\"1814\"],\"type\":\"COLLEGE\",\"phone\":\"+33 1 45 74 49 15\",\"name\":\"CLG-ANDRE MALRAUX-PARIS\",\"checksum\":\"34f00569fc359d4d52928e83e064b8141e48966d\",\"modified\":\"2019-05-09T03:45:00.932+02:00\",\"id\":\"61f1ea70-28c5-463b-8f91-9652d6b519a2\",\"UAI\":\"0752387M\",\"email\":\"ce.0752387M@ac-paris.fr\",\"ministry\":\"MINISTERE DE L'EDUCATION NATIONALE\",\"academy\":\"PARIS\",\"SIRET\":\"19752387100014\"}]",
            "firstName" => "Droit",
            "mobilePhone" => "[\"0635021768\"]"
          }
        }
      }
    } }

    cas = AuthentificationCasEntController.new
    responsables = cas.retrouve_les_responsables_legaux_depuis(h)
    assert_equal [resp_legal], responsables
  end

end
