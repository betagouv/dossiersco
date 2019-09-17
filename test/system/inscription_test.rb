# frozen_string_literal: true

require "test_helper"

class InscriptionTest < ActionDispatch::IntegrationTest

  test "Inscription simple" do
    eleve = Fabricate(:eleve, niveau_classe_ant: "5EME")
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve)

    Fabricate(:resp_legal, dossier_eleve: dossier_eleve, priorite: 1, lien_de_parente: "MERE")
    Fabricate(:resp_legal, dossier_eleve: dossier_eleve, priorite: 2, lien_de_parente: "PERE")

    visit "/"
    click_link "Inscrire un élève"
    visit "/connexion"
    assert_selector "h1", text: "Inscription au collège"

    fill_in "identifiant", with: eleve.identifiant
    fill_in "annee", with: eleve.annee_de_naissance
    fill_in "mois", with: eleve.mois_de_naissance
    fill_in "jour", with: eleve.jour_de_naissance
    click_button "Connexion"

    assert_selector "p", text: "Pour réinscrire votre enfant"

    click_button "Commencer l’inscription"

    assert_selector "h2", text: "Identité de l'élève"

    fill_in "eleve[prenom]", with: "Blanche"
    fill_in "eleve[nom]", with: "Mousse"
    fill_in "eleve[ville_naiss]", with: "Liege"
    select "BELGIQUE", from: "eleve_pays_naiss"
    select "BELGE", from: "eleve[nationalite]"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Responsable légal"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Renseignements médicaux"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Pièces à joindre"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Validation"

    click_button("Valider l'inscription")
    assert_selector "h2", text: "Réinscription de Blanche Mousse enregistrée"
  end

end
