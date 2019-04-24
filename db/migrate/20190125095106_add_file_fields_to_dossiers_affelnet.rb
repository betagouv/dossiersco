# frozen_string_literal: true

class AddFileFieldsToDossiersAffelnet < ActiveRecord::Migration[5.2]
  def change
    add_column :dossiers_affelnet, :nom, :string
    add_column :dossiers_affelnet, :prenom, :string
    add_column :dossiers_affelnet, :date_naissance, :date
    add_column :dossiers_affelnet, :etablissement_origine, :string
    add_column :dossiers_affelnet, :etablissement_accueil, :string
    add_column :dossiers_affelnet, :rang, :integer
    add_column :dossiers_affelnet, :dérogation, :string
    add_column :dossiers_affelnet, :formation_accueil, :string
    add_column :dossiers_affelnet, :decision_de_passage, :string
  end
end
