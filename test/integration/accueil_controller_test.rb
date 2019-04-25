# frozen_string_literal: true

require "test_helper"

class AccueilControllerTest < ActionDispatch::IntegrationTest

  def test_accueil
    get "/"
    assert response.parsed_body.include? "Inscription"
  end

  def test_entree_succes_eleve_non_inscrit
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [Fabricate(:resp_legal)])

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    follow_redirect!
    assert response.body.include? "Pour réinscrire votre enfant"
  end

  def _test_normalise_ine
    # en attendant de place cette methode en dehors du controller
    assert_equal "070803070AJ", normalise_alphanum(" %! 070803070aj _+ ")
  end

  def test_entree_succes_eleve_1
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve
    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    follow_redirect!
    assert response.body.include? "Pour réinscrire votre enfant"
  end

  def test_entree_mauvaise_date
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [Fabricate(:resp_legal)])
    eleve = dossier_eleve.eleve

    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: (eleve.jour_de_naissance.to_i + 1.days).to_s
    }
    post "/identification", params: params

    follow_redirect!
    message_erreur = "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
    assert response.body.include?(html_escape(message_erreur))
  end

  def test_entree_mauvais_identifiant_et_date
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve
    params = {
      identifiant: "MAUVAISIDENTIFIANT",
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params

    follow_redirect!
    message_erreur = "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
    assert response.body.include?(html_escape(message_erreur))
  end

  def test_nom_college_accueil
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve
    identification(eleve)
    follow_redirect!
    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal "Collège #{dossier_eleve.etablissement.nom}", doc.xpath("//div//h1/text()").to_s
  end

  def identification(eleve)
    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
  end

  def test_modification_lieu_naiss_eleve
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve
    identification(eleve)

    post "/eleve", params: { ville_naiss: "Beziers", prenom: "Edith" }
    get "/eleve"
    assert response.parsed_body.include? "Edith"
    assert response.parsed_body.include? "Beziers"
  end

  def test_modifie_une_information_de_eleve_preserve_les_autres_informations
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    post "/eleve", params: { prenom: "Edith" }
    get "/eleve"
    assert response.parsed_body.include? "Edith"
  end

  def test_accueil_et_inscription
    post "/identification", params: { identifiant: "1", annee: "1995", mois: "11", jour: "19" }
    follow_redirect!
    assert response.parsed_body.include? "inscription"
  end

  test "ramène parent à dernière étape incomplète" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/eleve", params: { Espagnol: true, Latin: true }
    get "/famille"

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    follow_redirect!

    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal "Responsable légal", doc.css("body > main > section > form > h2").text
  end

  test "une famille remplit l'etape administration" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    post "/identification", params: {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    get "/administration"
    post "/administration", params: {
      demi_pensionnaire: true,
      autorise_sortie: true,
      renseignements_medicaux: true,
      autorise_photo_de_classe: false
    }
    get "/administration"

    parsed_body = response.parsed_body.gsub(/\s/, "")
    assert parsed_body.include? "id='demi_pensionnaire' checked".gsub(/\s/, "")
    assert parsed_body.include? "id='autorise_sortie' checked".gsub(/\s/, "")
    assert parsed_body.include? "id='renseignements_medicaux' checked".gsub(/\s/, "")
    assert parsed_body.include? "id='autorise_photo_de_classe' checked".gsub(/\s/, "")
  end

  # le masquage du formulaire de contact se fait en javascript
  test "html du contact present dans page quand pas encore de contact" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    get "/famille"

    doc = Nokogiri::HTML(response.parsed_body)
    assert_not_nil doc.css("input#tel_principal_urg").first
  end

  test "ramene à la dernire etape visitée plutot que l'etape la plus avancée" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    eleve = dossier_eleve.eleve

    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    post "/famille"
    get "/eleve"
    post "/deconnexion"
    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    follow_redirect!
    assert response.parsed_body.include? html_escape("Identité de l'élève")
  end

  test "ramene à l'etape confirmation pour la satisfaction" do
    resp_legal = Fabricate(:resp_legal)
    eleve = Fabricate(:eleve)
    Fabricate(:dossier_eleve, eleve: eleve, resp_legal: [resp_legal])
    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    get "/confirmation"
    post "/satisfaction"
    post "/deconnexion"
    params = {
      identifiant: eleve.identifiant,
      annee: eleve.annee_de_naissance,
      mois: eleve.mois_de_naissance,
      jour: eleve.jour_de_naissance
    }
    post "/identification", params: params
    follow_redirect!

    expected = "L'inscription ne sera validée qu'à réception d'un email de confirmation"
    assert response.parsed_body.include?(expected)
  end

end
