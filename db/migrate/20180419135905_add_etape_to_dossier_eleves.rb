# frozen_string_literal: true

class AddEtapeToDossierEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :etape, :string, default: 'accueil'
  end
end
