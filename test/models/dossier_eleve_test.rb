# frozen_string_literal: true

require "test_helper"

class DossierEleveTest < ActiveSupport::TestCase

  test "a une fabrique valide" do
    assert Fabricate.build(:dossier_eleve).valid?
  end

  test "donne la liste des pièces jointes vierges" do
    etablissement = Fabricate(:etablissement)
    piece_attendue = Fabricate(:piece_attendue, etablissement: etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)

    assert_equal 1, dossier_eleve.pieces_jointes.count
    assert_nil dossier_eleve.pieces_jointes[0].id
    assert_equal piece_attendue, dossier_eleve.pieces_jointes[0].piece_attendue
  end

  test "donne la liste avec la pièce jointe" do
    etablissement = Fabricate(:etablissement)
    piece_attendue = Fabricate(:piece_attendue, etablissement: etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    piece_jointe = Fabricate(:piece_jointe,
                             dossier_eleve: dossier_eleve,
                             piece_attendue: piece_attendue)

    assert_equal 1, dossier_eleve.pieces_jointes.count
    assert_equal piece_jointe, dossier_eleve.pieces_jointes[0]
    assert_equal piece_attendue, dossier_eleve.pieces_jointes[0].piece_attendue
  end

  test "#pieces_manquantes? renvoie true s'il manque des pieces obligatoires" do
    etablissement = Fabricate(:etablissement)
    piece_attendue_facultative = Fabricate(:piece_attendue,
                                           obligatoire: false,
                                           etablissement: etablissement)
    piece_attendue_obligatoire = Fabricate(:piece_attendue,
                                           obligatoire: true,
                                           etablissement: etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    Fabricate(:piece_jointe,
              dossier_eleve: dossier_eleve,
              piece_attendue: piece_attendue_facultative)

    assert dossier_eleve.pieces_manquantes?
    assert_equal [piece_attendue_obligatoire], dossier_eleve.pieces_manquantes
  end

  test "#pieces_manquantes? renvoie false si les pieces obligatoires sont présentes" do
    etablissement = Fabricate(:etablissement)
    Fabricate(:piece_attendue,
              obligatoire: false,
              etablissement: etablissement)
    piece_attendue_obligatoire = Fabricate(:piece_attendue,
                                           obligatoire: true,
                                           etablissement: etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    Fabricate(:piece_jointe,
              dossier_eleve: dossier_eleve,
              piece_attendue: piece_attendue_obligatoire)

    assert_not dossier_eleve.pieces_manquantes?
    assert_equal [], dossier_eleve.pieces_manquantes
  end

  test "#a_convoquer renvoie la liste des élèves à convoquer sur dossiersco" do
    etablissement = Fabricate(:etablissement)
    eleve_jamais_connecte = Fabricate(:dossier_eleve,
                                      etat: "pas connecté",
                                      etablissement: etablissement)
    eleve_connecte = Fabricate(:dossier_eleve, etat: "connecté", etablissement: etablissement)
    Fabricate(:dossier_eleve, etat: "en attente", etablissement: etablissement)
    Fabricate(:dossier_eleve, etat: "validé", etablissement: etablissement)

    expected = [eleve_jamais_connecte, eleve_connecte]
    assert_equal expected.sort, DossierEleve.pour(etablissement).a_convoquer.sort
  end

  test "#par_authentification avec identifiant saisi en minuscule" do
    eleve = Fabricate(:eleve, identifiant: "UNINE")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal dossier, DossierEleve.par_authentification("un_ine", eleve.jour_de_naissance, eleve.mois_de_naissance, eleve.annee_de_naissance)
  end

  test "#par_authentification fonctionne aussi avec un identifiant en majuscule" do
    eleve = Fabricate(:eleve, identifiant: "ENMAJUSCULE")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal dossier, DossierEleve.par_authentification("EnMaJuScUlE", eleve.jour_de_naissance, eleve.mois_de_naissance, eleve.annee_de_naissance)
  end

  test "#par_authentification ne contient que des alphanums" do
    eleve = Fabricate(:eleve, identifiant: "ALPHANUM1234")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal dossier, DossierEleve.par_authentification("alpha,num;1234!", eleve.jour_de_naissance, eleve.mois_de_naissance, eleve.annee_de_naissance)
  end

  test "ajoute un message à envoyer pour la relance SMS" do
    assert_equal 0, Message.count
    dossier = Fabricate(:dossier_eleve, resp_legal: [Fabricate(:resp_legal)])
    dossier.relance_sms
    assert_equal 1, Message.count
  end

  test "#par_authentification avec des jours et mois sur deux digits" do
    eleve = Fabricate(:eleve, identifiant: 'INE', date_naiss: "2006-12-11")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    Fabricate(:dossier_eleve, eleve: Fabricate(:eleve, identifiant: 'INE', date_naiss: "2006-02-03"))
    assert_equal dossier, DossierEleve.par_authentification("ine", "11", "12", "2006")
  end

  test "#par_authentification avec des jours et mois sur un seul digit" do
    Fabricate(:dossier_eleve, eleve: Fabricate(:eleve, identifiant: 'INE', date_naiss: "2006-12-11"))
    eleve = Fabricate(:eleve, identifiant: 'INE', date_naiss: "2006-02-03")
    dossier = Fabricate(:dossier_eleve, eleve: eleve)
    assert_equal dossier, DossierEleve.par_authentification("ine", "3", "2", "2006")
  end

end
