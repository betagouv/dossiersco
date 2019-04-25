# frozen_string_literal: true

class CreateTableTacheImports < ActiveRecord::Migration[5.1]

  def change
    create_table :tache_imports do |t|
      t.string :statut
      t.string :url
      t.integer :etablissement_id
      t.datetime :created_at
    end
  end

end
