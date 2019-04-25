# frozen_string_literal: true

class AddDerniereEtape < ActiveRecord::Migration[5.2]

  def change
    add_column :dossier_eleves, :derniere_etape, :string
    rename_column :dossier_eleves, :etape, :etape_la_plus_avancee
  end

end
