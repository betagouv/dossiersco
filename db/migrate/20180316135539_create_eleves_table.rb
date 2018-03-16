class CreateElevesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :eleves do |t|
      t.string :identifiant
      t.string :prenom
      t.string :nom
      t.string :sexe
      t.string :ville_naiss
      t.string :nationalite
      t.string :classe_ant
      t.string :ets_ant
      t.string :lv2
      t.string :date_naiss
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end


