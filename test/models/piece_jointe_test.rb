require 'test_helper'

class PieceJointeTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:piece_jointe).valid?
  end

  test "renvoie le nom de l'établissement" do
    etablissement = Fabricate(:etablissement, nom: 'Arago')
    dossier = Fabricate(:dossier_eleve, etablissement: etablissement)
    piece = Fabricate(:piece_jointe, dossier_eleve: dossier)
    assert_equal 'Arago', piece.nom_etablissement
  end
end