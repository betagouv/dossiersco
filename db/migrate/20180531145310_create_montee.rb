class CreateMontee < ActiveRecord::Migration[5.1]
  def change
    create_table :montees do |t|
      t.integer :niveau_ant
      t.integer :etablissement_id
    end

    create_table :demandabilites do |t|
      t.integer :montee_id
      t.integer :option_id
    end

    create_table :abandonnabilites do |t|
      t.integer :montee_id
      t.integer :option_id
    end

    add_column :eleves, :montee_id, :integer
    add_column :options, :modalite, :string

    remove_column :options, :obligatoire
    remove_column :options, :niveau_debut
    remove_column :options, :etablissement_id
  end
end
