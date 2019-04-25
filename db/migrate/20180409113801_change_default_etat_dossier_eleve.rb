# frozen_string_literal: true

class ChangeDefaultEtatDossierEleve < ActiveRecord::Migration[5.1]

  def change
    change_column :dossier_eleves, :etat, :string, default: "pas connecté"
  end

end
