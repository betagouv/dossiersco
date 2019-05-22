class CreateFichierATelechargers < ActiveRecord::Migration[5.2]
  def change
    create_table :fichier_a_telechargers do |t|
      t.references :etablissement, foreign_key: true
      t.string :contenu

      t.timestamps
    end
  end
end
