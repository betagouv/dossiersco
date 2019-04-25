# frozen_string_literal: true

class AddAdresseAnt < ActiveRecord::Migration[5.1]

  def change
    add_column :resp_legals, :adresse_ant, :string
    add_column :resp_legals, :ville_ant, :string
    add_column :resp_legals, :code_postal_ant, :string
    add_column :tache_imports, :traitement, :string, default: "tout"
  end

end
