class RemoveFichierToPiecesJointes < ActiveRecord::Migration[5.2]
  def change
    PieceJointe.all.each do |piece|
      next unless piece.fichier.present?
      piece.fichier[0] = piece.fichier
    end
    remove_column :pieces_jointes, :fichier, :string
  end
end
