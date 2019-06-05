# frozen_string_literal: true

require "test_helper"

class InscriptionTest < ActionDispatch::IntegrationTest

  test "Inscription simple" do
    eleve = Fabricate(:eleve, niveau_classe_ant: "5EME")
    dossier_eleve = Fabricate(:dossier_eleve, eleve: eleve)

    Fabricate(:resp_legal, dossier_eleve: dossier_eleve, priorite: 1, lien_de_parente: "MERE")
    Fabricate(:resp_legal, dossier_eleve: dossier_eleve, priorite: 2, lien_de_parente: "PERE")

    visit "/"
    assert_selector "h1", text: "Inscription au collège"

    fill_in "identifiant", with: eleve.identifiant
    fill_in "annee", with: eleve.annee_de_naissance
    fill_in "mois", with: eleve.mois_de_naissance
    fill_in "jour", with: eleve.jour_de_naissance
    click_button "Connexion"

    assert_selector "p", text: "Pour réinscrire votre enfant"

    click_button "Commencer l’inscription"

    assert_selector "h2", text: "Identité de l'élève"

    fill_in "prenom", with: "Blanche"
    fill_in "nom", with: "Mousse"
    fill_in "ville_naiss", with: "Liege"
    fill_in "pays_naiss", with: "belgique"
    fill_in "nationalite", with: "belge"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Responsable légal"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Renseignements médicaux"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Pièces à joindre"

    click_button("Enregistrer et continuer")
    assert_selector "h2", text: "Validation"

    click_button("Valider l'inscription")
    assert_selector "h2", text: "Réinscription enregistrée"
  end

end
