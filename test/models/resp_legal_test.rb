# frozen_string_literal: true

require 'test_helper'

class RespLegalTest < ActiveSupport::TestCase
  def test_a_un_fabricant_valid
    assert Fabricate.build(:resp_legal).valid?
  end

  def test_detection_adresses_identiques_cas_degenere
    assert RespLegal.new.adresse_inchangee
  end

  def test_detection_adresses_identiques
    rl = RespLegal.new(
      adresse_ant: '4 IMPASSE MORLET',
      ville_ant: 'PARIS',
      code_postal_ant: '75011',
      adresse: "4 impasse Morlet\n",
      ville: "  Paris\r",
      code_postal: '75 011'
    )
    assert rl.adresse_inchangee
  end

  def test_meme_adresse
    r = RespLegal.new adresse: '42 rue', code_postal: '75020', ville: 'Paris'
    assert r.meme_adresse(r)
    assert r.meme_adresse(RespLegal.new(adresse: r.adresse, code_postal: r.code_postal, ville: r.ville))
    assert !r.meme_adresse(nil)
    assert !r.meme_adresse(RespLegal.new(adresse: '30',      code_postal: r.code_postal, ville: r.ville))
    assert !r.meme_adresse(RespLegal.new(adresse: r.adresse, code_postal: '59001',       ville: r.ville))
    assert !r.meme_adresse(RespLegal.new(adresse: r.adresse, code_postal: r.code_postal, ville: 'Lyon'))
  end

  def test_adresse_inchangee_si_ancienne_vide
    responsable_legal = RespLegal.new adresse: '42 rue', code_postal: '75020', ville: 'Paris', adresse_ant: nil, ville_ant: nil, code_postal_ant: nil
    assert responsable_legal.adresse_inchangee
  end
end
