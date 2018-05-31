class CreateMontee < ActiveRecord::Migration[5.1]
  def change
    create_table :montees do |t|
      t.integer :niveau_ant
      t.string :division_ant
      t.integer :etablissement_id
    end

    add_column :eleves, :montee_id, :integer
    add_column :options, :montee_id, :integer
    remove_column :options, :etablissement_id

    create_table :abandons do |t|
      t.integer :eleve_id
      t.integer :option_id
    end
  end
end
