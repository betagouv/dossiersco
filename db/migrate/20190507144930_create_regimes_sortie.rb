class CreateRegimesSortie < ActiveRecord::Migration[5.2]
  def change
    create_table :regimes_sortie do |t|
      t.string :nom
      t.string :description
      t.references :etablissement, foreign_key: true
    end
  end
end
