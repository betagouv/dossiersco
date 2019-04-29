# frozen_string_literal: true

require "test_helper"

class RespLegalTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valid
    assert Fabricate.build(:resp_legal).valid?
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
    assert_equal '99', RespLegal.code_profession_from("")
  end

  test "retourne un code profession 45 pour les fonctionnaires" do
    assert_equal '45', RespLegal.code_profession_from("Profession intermédiaire administrative de la fonction publique")
  end

end
