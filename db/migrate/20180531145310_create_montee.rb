class CreateMontee < ActiveRecord::Migration[5.1]
  def change
    create_table :montees do |t|
#      t.integer :niveau_ant
#      t.integer :etablissement_id
      t.string :division_ant
    end

    create_table :demandabilites do |t|
       t.integer :montee_id
       t.integer :option_id
    end

    add_column :eleves, :montee_id, :integer
    add_column :options, :modalite, :string

  end
end
