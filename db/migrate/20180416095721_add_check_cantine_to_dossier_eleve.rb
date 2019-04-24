# frozen_string_literal: true

class AddCheckCantineToDossierEleve < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :check_reglement_cantine, :boolean, default: false
    add_column :dossier_eleves, :check_paiement_cantine, :boolean, default: false
  end
end
