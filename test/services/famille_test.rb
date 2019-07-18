# frozen_string_literal: true

require "test_helper"

class FamilleTest < ActiveSupport::TestCase

  test "#retouve_un_email lève une exception si aucun email trouvé" do
    resp1 = Fabricate(:resp_legal, email: nil, priorite: 1)
    resp2 = Fabricate(:resp_legal, email: nil, priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_raise ExceptionAucunEmailRetrouve do
      Famille.new.retrouve_un_email(dossier)
    end
  end

  test "#retouve_un_email retourne le mail du resp1 quand renseigné" do
    resp1 = Fabricate(:resp_legal, email: "henri@ford.com", priorite: 1)
    resp2 = Fabricate(:resp_legal, email: nil, priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "henri@ford.com", Famille.new.retrouve_un_email(dossier)
  end

  test "#retouve_un_email retourne le mail du resp2 quand email resp1 non renseigné" do
    resp1 = Fabricate(:resp_legal, email: nil, priorite: 1)
    resp2 = Fabricate(:resp_legal, email: "malcom@x.com", priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "malcom@x.com", Famille.new.retrouve_un_email(dossier)
  end

  test "#retouve_un_email retourne le mail du resp1 quand les deux représentant ont un email" do
    resp1 = Fabricate(:resp_legal, email: "henri@ford.com", priorite: 1)
    resp2 = Fabricate(:resp_legal, email: "malcom@x.com", priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "henri@ford.com", Famille.new.retrouve_un_email(dossier)
  end

  test "#nettoyage_telephone ne change pas si les numéro de téléphone pour l'enregistrer sans espace" do
    famille = Famille.new
    params = base_parametre_famille

    assert_equal params, famille.nettoyage_telephone(params)
  end

  test "#nettoyage_telephone supprime les espaces quand il y en a dans le tel_portable" do
    famille = Famille.new
    params = base_parametre_famille
    params["resp_legal_attributes"]["0"]["tel_portable"] = "02 70 51 44 33"

    expected_tel_portable = "0270514433"

    assert_equal expected_tel_portable, famille.nettoyage_telephone(params)["resp_legal_attributes"]["0"]["tel_portable"]
  end

  test "#nettoyage_telephone supprime les espaces quand il y en a dans le tel_portable y compris sur le deuxième représentant" do
    famille = Famille.new
    params = base_parametre_famille
    params["resp_legal_attributes"]["1"]["tel_portable"] = "02 70 51 44 33"

    expected_tel_portable = "0270514433"

    assert_equal expected_tel_portable, famille.nettoyage_telephone(params)["resp_legal_attributes"]["1"]["tel_portable"]
  end

  test "#nettoyage_telephone supprime les espaces quand il y en a dans le tel_personnel" do
    famille = Famille.new
    params = base_parametre_famille
    params["resp_legal_attributes"]["1"]["tel_personnel"] = "02 70 51 44 33"

    expected_tel_portable = "0270514433"

    assert_equal expected_tel_portable, famille.nettoyage_telephone(params)["resp_legal_attributes"]["1"]["tel_personnel"]
  end

  test "#nettoyage_telephone supprime les espaces quand il y en a dans le tel_professionnel" do
    famille = Famille.new
    params = base_parametre_famille
    params["resp_legal_attributes"]["1"]["tel_professionnel"] = "02 70 51 44 33"

    expected_tel_portable = "0270514433"

    assert_equal expected_tel_portable, famille.nettoyage_telephone(params)["resp_legal_attributes"]["1"]["tel_professionnel"]
  end

  test "#nettoyage_telephone nettoie également les téléphones du contact d'urgence" do
    famille = Famille.new
    params = base_parametre_famille
    params["contact_urgence_attributes"]["tel_principal"] = "02 70 51 44 33"
    params["contact_urgence_attributes"]["tel_secondaire"] = "02 44 55 44 33"

    expected_tel_principal = "0270514433"
    expected_tel_secondaire = "0244554433"

    assert_equal expected_tel_principal, famille.nettoyage_telephone(params)["contact_urgence_attributes"]["tel_principal"]
    assert_equal expected_tel_secondaire, famille.nettoyage_telephone(params)["contact_urgence_attributes"]["tel_secondaire"]
  end

  test "#nettoyage_telephone ne fait rien si les paramètres sont vide" do
    famille = Famille.new
    params = {}
    assert_equal params, famille.nettoyage_telephone(params)
  end

  def base_parametre_famille
    {
      "resp_legal_attributes" => {
        "0" => {
          "lien_de_parente" => "MERE",
          "prenom" => "Lola",
          "nom" => "Mathiéu",
          "code_postal" => "75012",
          "adresse" => "98 Passage de Caumartin",
          "ville" => "TEST",
          "ville_etrangere" => "",
          "pays" => "100",
          "tel_personnel" => "0345836291",
          "tel_portable" => "0270514433",
          "tel_professionnel" => "",
          "email" => "",
          "profession" => "professeur, profession scientifique",
          "communique_info_parents_eleves" => "false",
          "enfants_a_charge" => "1",
          "id" => "702"
        },
        "1" => {
          "lien_de_parente" => "MERE",
          "prenom" => "",
          "nom" => "",
          "code_postal" => "",
          "adresse" => "",
          "ville" => "",
          "ville_etrangere" => "",
          "pays" => "",
          "tel_personnel" => "",
          "tel_portable" => "",
          "tel_professionnel" => "",
          "email" => "",
          "profession" => "",
          "communique_info_parents_eleves" => "",
          "id" => "1067"
        }
      },
      "contact_urgence_attributes" => {
        "lien_avec_eleve" => "",
        "prenom" => "",
        "nom" => "",
        "tel_principal" => "",
        "tel_secondaire" => ""
      }
    }
  end

end
