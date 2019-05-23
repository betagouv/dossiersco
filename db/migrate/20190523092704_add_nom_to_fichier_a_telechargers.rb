class AddNomToFichierATelechargers < ActiveRecord::Migration[5.2]
  def change
    add_column :fichier_a_telechargers, :nom, :string
  end
end
