# frozen_string_literal: true

class AddFichierToTacheImports < ActiveRecord::Migration[5.2]
  def change
    add_column :tache_imports, :fichier, :string
  end
end
