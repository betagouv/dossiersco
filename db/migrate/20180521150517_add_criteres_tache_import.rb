# frozen_string_literal: true

class AddCriteresTacheImport < ActiveRecord::Migration[5.1]
  def change
    add_column :tache_imports, :nom_a_importer, :string
    add_column :tache_imports, :prenom_a_importer, :string
  end
end
