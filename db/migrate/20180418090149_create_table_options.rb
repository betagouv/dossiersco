class CreateTableOptions < ActiveRecord::Migration[5.1]
  def change
  	create_table :options do |t|
      t.string :nom
      t.integer :niveau_debut
      t.integer :etablissement_id
    end 
  end
end
