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
    dossier = Fabricate(:dossier_eleve, identifiant: "UNINE")
    assert_equal dossier, DossierEleve.par_authentification("un_ine",
                                                            dossier.jour_de_naissance, dossier.mois_de_naissance, dossier.annee_de_naissance)
  end

  test "#par_authentification fonctionne aussi avec un identifiant en majuscule" do
    dossier = Fabricate(:dossier_eleve, identifiant: "ENMAJUSCULE")
    assert_equal dossier, DossierEleve.par_authentification("EnMaJuScUlE",
                                                            dossier.jour_de_naissance, dossier.mois_de_naissance, dossier.annee_de_naissance)
  end

  test "#par_authentification ne contient que des alphanums" do
    dossier = Fabricate(:dossier_eleve, identifiant: "ALPHANUM1234")
    assert_equal dossier, DossierEleve.par_authentification("alpha,num;1234!",
                                                            dossier.jour_de_naissance,
                                                            dossier.mois_de_naissance,
                                                            dossier.annee_de_naissance)
  end

  test "ajoute un message à envoyer pour la relance SMS" do
    assert_equal 0, Message.count
    dossier = Fabricate(:dossier_eleve, resp_legal: [Fabricate(:resp_legal)])
    dossier.relance_sms
    assert_equal 1, Message.count
  end

  test "#par_authentification avec des jours et mois sur deux digits" do
    dossier = Fabricate(:dossier_eleve, identifiant: "INE", date_naiss: "2006-12-11")
    Fabricate(:dossier_eleve, identifiant: "INE", date_naiss: "2006-02-03")
    assert_equal dossier, DossierEleve.par_authentification("ine", "11", "12", "2006")
  end

  test "#par_authentification avec des jours et mois sur un seul digit" do
    Fabricate(:dossier_eleve, identifiant: "INE", date_naiss: "2006-12-11")
    dossier = Fabricate(:dossier_eleve, identifiant: "INE", date_naiss: "2006-02-03")
    assert_equal dossier, DossierEleve.par_authentification("ine", "3", "2", "2006")
  end

  test "#deja_connecte? true pour les etats autre que _pas connecté_" do
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:connecte])
    assert dossier.deja_connecte?
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente])
    assert dossier.deja_connecte?
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente_de_validation])
    assert dossier.deja_connecte?
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:valide])
    assert dossier.deja_connecte?
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:sortant])
    assert dossier.deja_connecte?
  end

  test "#deja_connecte? false pour les etats _pas connecté_" do
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:pas_connecte])
    assert !dossier.deja_connecte?
  end

  test "moyens_de_communication_electronique renvoie les emails et numéro de portable des resp légaux" do
    premier_representant = Fabricate(:resp_legal,
                                     email: "truc@example.com",
                                     tel_professionnel: "0788888888",
                                     tel_personnel: "0123456789",
                                     tel_portable: nil,
                                     priorite: 1,
                                     nom: "un")
    deuxieme_representant = Fabricate(:resp_legal,
                                      tel_professionnel: "0699999999",
                                      tel_portable: "0723456789",
                                      email: nil,
                                      tel_personnel: nil,
                                      nom: "deux")

    dossier = Fabricate(:dossier_eleve, resp_legal: [premier_representant, deuxieme_representant])

    expected = {
      premier_representant.nom_complet => ["truc@example.com", "0788888888"],
      deuxieme_representant.nom_complet => %w[0699999999 0723456789]
    }
    assert_equal expected, dossier.moyens_de_communication_electronique
  end

  test "[retour siecle] classe les options obligatoires selon leur rang" do
    mef = Fabricate(:mef)
    option_de_rang_2 = Fabricate(:option_pedagogique, code_matiere: "020002")
    option_de_rang_1 = Fabricate(:option_pedagogique, code_matiere: "010001")
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_de_rang_2, rang_option: 2)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_de_rang_1, rang_option: 1)
    dossier = Fabricate(:dossier_eleve,
                        mef_destination: mef,
                        options_pedagogiques: [option_de_rang_2, option_de_rang_1])

    assert_equal [option_de_rang_1, option_de_rang_2], dossier.options_triees_par_rang
  end

  test "[retour siecle] classe les options obligatoires avant les options facultatives" do
    mef = Fabricate(:mef)
    option_facultative = Fabricate(:option_pedagogique, code_matiere: "020002")
    option_obligatoire = Fabricate(:option_pedagogique, code_matiere: "010001")
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_facultative, rang_option: nil)
    Fabricate(:mef_option_pedagogique, mef: mef, option_pedagogique: option_obligatoire, rang_option: 1)
    dossier = Fabricate(:dossier_eleve,
                        mef_destination: mef,
                        options_pedagogiques: [option_facultative, option_obligatoire])

    assert_equal [option_obligatoire, option_facultative], dossier.options_triees_par_rang
  end

  test "dossier non valide si état différent de valide" do
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:en_attente_de_validation])
    assert !dossier.valide?
  end

  test "dossier valide si état validé" do
    dossier = Fabricate(:dossier_eleve, etat: DossierEleve::ETAT[:valide])
    assert dossier.valide?
  end

  test "un dossier élève a le nom d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, nom: "Alice")
    assert_equal "Alice", dossier.nom
  end

  test "un dossier élève a les prenoms d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, prenom: "Alice", prenom_2: "Alice2", prenom_3: "Alice3")
    assert_equal "Alice", dossier.prenom
    assert_equal "Alice2", dossier.prenom_2
    assert_equal "Alice3", dossier.prenom_3
  end

  test "un dossier élève a l'identifiant d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, identifiant: "0123456789U")
    assert_equal "0123456789U", dossier.identifiant
  end

  test "un dossier élève a la ville de naissance d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, ville_naiss: "Chateldon")
    assert_equal "Chateldon", dossier.ville_naiss
  end

  test "un dossier élève a le pays de naissance d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, pays_naiss: "100")
    assert_equal "100", dossier.pays_naiss
  end

  test "un dossier élève a le sexe d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, sexe: "Féminin")
    assert_equal "Féminin", dossier.sexe
  end

  test "un dossier élève a la nationalite d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, nationalite: "FRANCE")
    assert_equal "FRANCE", dossier.nationalite
  end

  test "un dossier élève a la classe_ant d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, classe_ant: "5C")
    assert_equal dossier.classe_ant, dossier.classe_ant
  end

  test "un dossier élève a la date_naiss d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, date_naiss: "2006-05-24")
    assert_equal dossier.date_naiss, dossier.date_naiss
  end

  test "un dossier élève a le niveau_classe_ant  d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, niveau_classe_ant: "5EME")
    assert_equal dossier.niveau_classe_ant, dossier.niveau_classe_ant
  end

  test "un dossier élève a l  d'un élève" do
    dossier = Fabricate.build(:dossier_eleve, id_prv_ele: "24463")
    assert_equal dossier.id_prv_ele, dossier.id_prv_ele
  end

  test "a une année de naissance" do
    dossier = Fabricate.build(:dossier_eleve, date_naiss: "2004-04-27")
    assert_equal "2004", dossier.annee_de_naissance
  end

  test "a un mois de naissance" do
    dossier = Fabricate.build(:dossier_eleve, date_naiss: "2004-04-27")
    assert_equal "04", dossier.mois_de_naissance
  end

  test "a un jour de naissance" do
    dossier = Fabricate.build(:dossier_eleve, date_naiss: "2004-04-27")
    assert_equal "27", dossier.jour_de_naissance
  end

  test "#par_authentification" do
    dossier = Fabricate(:dossier_eleve)
    assert_equal dossier, DossierEleve.par_authentification(
      dossier.identifiant,
      dossier.jour_de_naissance,
      dossier.mois_de_naissance,
      dossier.annee_de_naissance
    )

    dossier = Fabricate(:dossier_eleve, identifiant: "TRUC")
    assert_equal dossier, DossierEleve.par_authentification("truc", dossier.jour_de_naissance, dossier.mois_de_naissance, dossier.annee_de_naissance)
  end

  test "#par_authentification avec des jour et mois sur 2 digits" do
    dossier = Fabricate(:dossier_eleve, identifiant: "TRUC", date_naiss: "2006-12-23")
    assert_equal dossier, DossierEleve.par_authentification("truc", "23", "12", "2006")
  end

  test "#par_authentification avec des jour et mois sur 1 digits" do
    dossier = Fabricate(:dossier_eleve, identifiant: "TRUC", date_naiss: "2006-01-04")
    assert_equal dossier, DossierEleve.par_authentification("truc", "4", "1", "2006")
  end

end
