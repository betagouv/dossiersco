# frozen_string_literal: true

require "test_helper"

class RespLegalTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valid
    assert Fabricate.build(:resp_legal).valid?
  end

  %i[lien_de_parente prenom nom adresse code_postal ville profession].each do |champ|
    test "invalid si #{champ} n'est pas renseigné" do
      resp = Fabricate.build(:resp_legal)
      resp.send("#{champ}=", nil)
      assert resp.invalid?
    end
  end

  test "enfants à charge obligatoire si représentant légal de priorité 1" do
    assert Fabricate.build(:resp_legal, priorite: 1, enfants_a_charge: nil).invalid?
  end

  test "au moins un téléphone renseigné" do
    assert Fabricate.build(:resp_legal, tel_portable: nil, tel_professionnel: nil, tel_personnel: nil).invalid?
    assert Fabricate.build(:resp_legal, tel_portable: "0123456789", tel_professionnel: nil, tel_personnel: nil).valid?
    assert Fabricate.build(:resp_legal, tel_portable: nil, tel_professionnel: "0123456789", tel_personnel: nil).valid?
    assert Fabricate.build(:resp_legal, tel_portable: nil, tel_professionnel: nil, tel_personnel: "0123456789").valid?
  end

  def test_detection_adresses_identiques_cas_degenere
    assert RespLegal.new.adresse_inchangee
  end

  def test_detection_adresses_identiques
    rl = RespLegal.new(
      adresse_ant: "4 IMPASSE MORLET",
      ville_ant: "PARIS",
      code_postal_ant: "75011",
      adresse: "4 impasse Morlet\n",
      ville: "  Paris\r",
      code_postal: "75 011"
    )
    assert rl.adresse_inchangee
  end

  test "même adresse avec sois" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    assert resp.meme_adresse(resp)
  end

  test "même adresse même sur un autre resp" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    autre_resp = RespLegal.new(
      adresse: resp.adresse,
      code_postal: resp.code_postal,
      ville: resp.ville
    )
    assert resp.meme_adresse(autre_resp)
  end

  test "nil n'est pas une même adresse" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    assert !resp.meme_adresse(nil)
  end

  test "si adresse est différent, ce n'est pas une même adresse" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    assert !resp.meme_adresse(RespLegal.new(
                                adresse: "30",
                                code_postal: resp.code_postal,
                                ville: resp.ville
                              ))
  end

  test "si le code_postal est différent, ce n'est pas une même adresse" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    assert !resp.meme_adresse(RespLegal.new(
                                adresse: resp.adresse,
                                code_postal: "59001",
                                ville: resp.ville
                              ))
  end

  test "si la ville est différent, ce n'est pas une même adresse" do
    resp = RespLegal.new adresse: "42 rue", code_postal: "75020", ville: "Paris"
    assert !resp.meme_adresse(RespLegal.new(
                                adresse: resp.adresse,
                                code_postal: resp.code_postal,
                                ville: "Lyon"
                              ))
  end

  def test_adresse_inchangee_si_ancienne_vide
    responsable_legal = RespLegal.new(
      adresse: "42 rue",
      code_postal: "75020",
      ville: "Paris",
      adresse_ant: nil,
      ville_ant: nil,
      code_postal_ant: nil
    )
    assert responsable_legal.adresse_inchangee
  end

  test "retourne un code profession 99 par défaut" do
    assert_equal "99", RespLegal.code_profession_from("")
  end

  test "retourne un code profession 45 pour les fonctionnaires" do
    assert_equal "45", RespLegal.code_profession_from("Profession intermédiaire administrative de la fonction publique")
  end

  test "representant_principal?" do
    assert Fabricate.build(:resp_legal, priorite: 1).representant_principal?
    assert !Fabricate.build(:resp_legal, priorite: 2).representant_principal?
  end

end
