# frozen_string_literal: true

class AddColonnesFichiersToDossierEleves < ActiveRecord::Migration[5.1]

  def change
    add_column :dossier_eleves, :photo_identite, :string
    add_column :dossier_eleves, :assurance_scolaire, :string
    add_column :dossier_eleves, :jugement_garde_enfant, :string
  end

end
