# frozen_string_literal: true

require "test_helper"

class EtablissementTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:etablissement).valid?
  end

  test "invalide dans UAI" do
    assert Fabricate.build(:etablissement, uai: nil).invalid?
  end

  test "invalide si le code postal n'a pas 5 chiffres" do
    assert Fabricate.build(:etablissement, code_postal: "x").invalid?
  end

  test "avec un code postal, departement renvoie les 2 premiers chiffres du code postal" do
    etablissement = Fabricate.build(:etablissement, code_postal: "77400")
    assert "77", etablissement.departement
  end

  test "sans code postal, departement renvoie une chaine vide" do
    etablissement = Fabricate.build(:etablissement, code_postal: nil)
    assert "", etablissement.departement
  end

  test "purge" do
    etablissement = Fabricate.create(:etablissement)
    dossier_eleve = Fabricate.create(:dossier_eleve, etablissement: etablissement)
    Fabricate.create(:tache_import, etablissement: etablissement)
    Fabricate.create(:mef, etablissement: etablissement)
    resp_legal = Fabricate(:resp_legal, dossier_eleve: dossier_eleve)
    piece_jointe = Fabricate(:piece_jointe, dossier_eleve: dossier_eleve)
    message = Fabricate(:message, dossier_eleve: dossier_eleve)
    contact_urgence = Fabricate(:contact_urgence, dossier_eleve: dossier_eleve)

    etablissement.purge_dossiers_eleves!

    assert_equal 0, etablissement.dossier_eleve.count
    assert_equal 0, etablissement.tache_import.count
    assert_not_equal 0, etablissement.mef.count

    assert_equal false, Message.exists?(message.id)
    assert_equal false, ContactUrgence.exists?(contact_urgence.id)
    assert_equal false, RespLegal.exists?(resp_legal.id)
    assert_equal false, PieceJointe.exists?(piece_jointe.id)
  end

  test "reconstruit l'email de sont chef d'établissement" do
    etablissement = Fabricate.build(:etablissement, uai: "0755433Y")
    assert_equal "ce.0755433Y@ac-paris.fr", etablissement.email_chef
  end

end
