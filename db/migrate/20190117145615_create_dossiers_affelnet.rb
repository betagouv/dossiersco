class CreateDossiersAffelnet < ActiveRecord::Migration[5.2]
  def change
    create_table :dossiers_affelnet do |t|
      t.string :fichier
      t.references :etablissement, foreign_key: true
    end
  end
end
