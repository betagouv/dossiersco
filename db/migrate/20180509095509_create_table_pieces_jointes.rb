# frozen_string_literal: true

class CreateTablePiecesJointes < ActiveRecord::Migration[5.1]
  def change
    create_table :piece_jointes do |t|
      t.string :clef
      t.integer :dossier_eleve_id
      t.integer :piece_attendue_id
    end
    create_table :piece_attendues do |t|
      t.string :nom
      t.string :code
      t.string :explication
      t.integer :etablissement_id
    end
  end
end
