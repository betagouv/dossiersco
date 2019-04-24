# frozen_string_literal: true

class SupprimeLeChampFichierDeLaTableDossiersAffelnet < ActiveRecord::Migration[5.2]
  def change
    remove_column :dossiers_affelnet, :fichier
  end
end
