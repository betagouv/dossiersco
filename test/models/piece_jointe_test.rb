# frozen_string_literal: true

require "test_helper"

class PieceJointeTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:piece_jointe).valid?
  end

  test "Ne contient que les états définis" do
    PieceJointe::ETATS.each do |_, etat|
      assert Fabricate.build(:piece_jointe, etat: etat).valid?
    end
    assert Fabricate.build(:piece_jointe, etat: "aze").invalid?
  end

  test "renvoie le nom de l'établissement" do
    etablissement = Fabricate(:etablissement, nom: "Arago")
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    piece = Fabricate(:piece_jointe, dossier_eleve: dossier)
    assert_equal "Arago", piece.nom_etablissement
  end

  test "valide la piece jointe" do
    piece = Fabricate(:piece_jointe, etat: PieceJointe::ETATS[:soumis])
    piece.valide!
    assert_equal PieceJointe::ETATS[:valide], piece.etat
  end

  test "invalide la piece jointe" do
    piece = Fabricate(:piece_jointe, etat: PieceJointe::ETATS[:soumis])
    piece.invalide!
    assert_equal PieceJointe::ETATS[:invalide], piece.etat
  end

  test "soumet la piece jointe" do
    piece = Fabricate.build(:piece_jointe, etat: nil)
    piece.soumet!
    assert_equal PieceJointe::ETATS[:soumis], piece.etat
  end

end
