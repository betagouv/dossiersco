class AddFichierToPiecesJointes < ActiveRecord::Migration[5.2]
  def change
    add_column :pieces_jointes, :fichier, :string
  end
end
