# frozen_string_literal: true

class AddOptionsOriginesToDossierEleve < ActiveRecord::Migration[5.2]

  def change
    add_column :dossier_eleves, :options_origines, :json, default: {}
  end

end
