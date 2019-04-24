# frozen_string_literal: true

class AddEtatDossierEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :etat, :string, default: 'pas_connecte'
  end
end
