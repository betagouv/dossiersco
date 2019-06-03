# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionDispatch::IntegrationTest

  include ApplicationHelper

  test "super_admin? fonctionne, même sans avoir créé la variable d'environnement SUPER_ADMIN" do
    ENV["SUPER_ADMIN"] = nil
    assert !super_admin?("Henri")
  end

  test "super_admin? fonctionne, avec nil en paramètre" do
    ENV["SUPER_ADMIN"] = "Henri"
    assert !super_admin?(nil)
  end

  test "super_admin? renvoie true quand l'identifiant est dans la variable d'environnement SUPER_ADMIN" do
    ENV["SUPER_ADMIN"] = "Henri"
    assert super_admin?("Henri")
  end

  test "super_admin? renvoie true peut importe la casse quand l'identifiant est dans la variable d'environnement SUPER_ADMIN" do
    ENV["SUPER_ADMIN"] = "henri"
    assert super_admin?("Henri")
  end

  test "super_admin? renvoie false quand l'identifiant n'est dans la variable d'environnement SUPER_ADMIN" do
    ENV["SUPER_ADMIN"] = "Henri"
    assert !super_admin?("Pascal")
  end

  test "super_admin? renvoie true sur un deuxième super admin" do
    ENV["SUPER_ADMIN"] = "Henri, Lucien"
    assert super_admin?("Lucien")
  end

  test "#affiche_etablissement(etablissement) sans UAI, affiche le nom et le département quand ils sont renseigné)" do
    etablissement = Fabricate(:etablissement, nom: "Papillon", code_postal: "30200")
    expected = "Papillon - #{etablissement.uai}"
    assert_equal expected, affiche_etablissement(etablissement)
  end

  test "transforme un texte en html" do
    texte = "blabla"
    assert_equal "<p>blabla</p>\n", markdown(texte)
  end

  test "liste du menu famille" do
    expected = %w[accueil eleve famille administration pieces_a_joindre validation]
    assert_equal expected, entrees_de_menu
  end

  test "quand l'étape est déjà passée, renvoie step-enabled" do
    dossier = Fabricate.build(:dossier_eleve, etape_la_plus_avancee: "administration")
    assert_equal "step step-enabled current done", classe_pour_menu("famillle", dossier)
  end

  test "quand l'étape est pas encore passée, renvoie step-disabled" do
    dossier = Fabricate.build(:dossier_eleve, etape_la_plus_avancee: "eleve")
    assert_equal "step step-disabled", classe_pour_menu("famille", dossier)
  end

  test "quand l'étape est l'étape courante, renvoie step-enabled et current" do
    dossier = Fabricate.build(:dossier_eleve, etape_la_plus_avancee: "famille")
    assert_equal "step step-enabled current", classe_pour_menu("famille", dossier)
  end

  test "#lien_menu # si step-disabled" do
    dossier = Fabricate.build(:dossier_eleve, etape_la_plus_avancee: "eleve")
    assert_equal "#", lien_menu("famille", dossier)
  end

  test "#lien_menu url si la page à déjà été vue" do
    dossier = Fabricate.build(:dossier_eleve, etape_la_plus_avancee: "administration")
    assert_equal "/famille", lien_menu("famille", dossier)
  end

  test "si l'option est ouverte et non suivi checkbox vierge" do
    mef_option = Fabricate(:mef_option_pedagogique, abandonnable: true)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_option.mef)

    assert ouverte?(dossier_eleve, mef_option.option_pedagogique)
  end

  test "si l'option est suivi et abandonnable checkbox cochée" do
    mef_option = Fabricate(:mef_option_pedagogique, abandonnable: true)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_option.mef)
    dossier_eleve.options_origines = { mef_option.option_pedagogique.id.to_s => { "nom" => mef_option.option_pedagogique.nom } }

    assert abandonnable?(dossier_eleve, mef_option.option_pedagogique)
  end

  test "si l'option est suivi et non abandonnable checkbox cochée et désactivé" do
    mef_option = Fabricate(:mef_option_pedagogique, abandonnable: false)
    dossier_eleve = Fabricate(:dossier_eleve, mef_destination: mef_option.mef)
    dossier_eleve.options_origines = { mef_option.option_pedagogique.id.to_s => { "nom" => mef_option.option_pedagogique.nom } }

    assert non_abandonnable?(dossier_eleve, mef_option.option_pedagogique)
  end

end
