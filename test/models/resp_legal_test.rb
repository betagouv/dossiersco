# frozen_string_literal: true

require "test_helper"

class RespLegalTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valid
    assert Fabricate.build(:resp_legal).valid?
  end

  def test_detection_adresses_identiques_cas_degenere
    assert RespLegal.new.adresse_inchangee?
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
    assert rl.adresse_inchangee?
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
    assert responsable_legal.adresse_inchangee?
  end

  test "renvoie un tableau vide si aucun moyen de communication renseigné" do
    representant = Fabricate.build(:resp_legal, email: nil, tel_personnel: nil, tel_portable: nil, tel_professionnel: nil)
    assert_equal [], representant.moyens_de_communication
  end

  test "renvoie l'email si renseigné" do
    representant = Fabricate.build(:resp_legal, email: "toto@example.com", tel_personnel: nil, tel_portable: nil, tel_professionnel: nil)
    assert_equal ["toto@example.com"], representant.moyens_de_communication
  end

  test "renvoie tel_professionnel si renseigné" do
    representant = Fabricate.build(:resp_legal, email: nil, tel_personnel: nil, tel_portable: nil, tel_professionnel: "0123456789")
    assert_equal ["0123456789"], representant.moyens_de_communication
  end

  test "renvoie tous les moyens de communication si tous renseignés" do
    representant = Fabricate.build(:resp_legal,
                                   email: "toto@example.com",
                                   tel_personnel: "01111111111",
                                   tel_portable: "06666666666",
                                   tel_professionnel: "0123456789")
    assert_equal ["toto@example.com", "01111111111", "0123456789", "06666666666"].sort, representant.moyens_de_communication.sort
  end

  test "nom_complet renvoie prénom et nom" do
    representant = Fabricate(:resp_legal, nom: "Marley", prenom: "Bob")
    assert_equal "Bob Marley", representant.nom_complet
  end

  test "tronque si pas de separateur" do
    adresse = "100 Back Street Paradise 11201 BROOKLYN NY / USA"
    resp_legal = Fabricate(:resp_legal,
                           adresse: adresse)

    assert_equal "100 Back Street Paradise 11201", resp_legal.ligne1_adresse_siecle
    assert_equal "BROOKLYN NY / USA", resp_legal.ligne2_adresse_siecle
  end

  test "aller jusqu'à 4 ligne d'adresse" do
    adresse = "Résidence le claricy 1 bâtiment C appart 4760 3 éme étage 290 vois des hauts de clairicy "
    # adresse = "Résidence le claricy 1 bâtiment C appart 4760 3 éme étage\r\n290 vois des hauts de clairicy "
    resp_legal = Fabricate(:resp_legal, adresse: adresse)

    assert_equal "Résidence le claricy 1 bâtiment C", resp_legal.ligne1_adresse_siecle
    assert_equal "appart 4760 3 éme étage 290 vois des", resp_legal.ligne2_adresse_siecle
    # assert_equal "appart 4760 3 éme étage\r\n290 vois des", resp_legal.ligne2_adresse_siecle
    assert_equal "hauts de clairicy", resp_legal.ligne3_adresse_siecle

    assert resp_legal.ligne1_adresse_siecle.length <= 38
    assert resp_legal.ligne2_adresse_siecle.length <= 38
    assert resp_legal.ligne3_adresse_siecle.length <= 38
  end

  test "supprime les retours à la ligne sur l'adresse" do
    adresse = <<~HERE
      20 RUE DU    VILLAGE
      BAT G
    HERE
    resp_legal = Fabricate(:resp_legal, adresse: adresse)
    assert_equal "20 RUE DU VILLAGE BAT G", resp_legal.ligne1_adresse_siecle
  end

end
