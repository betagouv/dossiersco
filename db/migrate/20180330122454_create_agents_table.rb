# frozen_string_literal: true

class CreateAgentsTable < ActiveRecord::Migration[5.1]

  def change
    create_table :agents do |t|
      t.string :identifiant
      t.string :prenom
      t.string :nom
      t.string :password
      t.integer :etablissement_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

end
