# frozen_string_literal: true

class RemoveCheckReglementCantineFromDossierEleve < ActiveRecord::Migration[5.1]

  def change
    remove_column :dossier_eleves, :check_reglement_cantine
  end

end
