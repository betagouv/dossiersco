class AddFichiersToPiecesJointes < ActiveRecord::Migration[5.2]
  def change
    add_column :pieces_jointes, :fichiers, :json, default: {}
  end
end
