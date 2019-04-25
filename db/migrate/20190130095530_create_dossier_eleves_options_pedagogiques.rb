# frozen_string_literal: true

class CreateDossierElevesOptionsPedagogiques < ActiveRecord::Migration[5.2]

  def change
    create_table :dossier_eleves_options_pedagogiques do |t|
      t.references :dossier_eleve, foreign_key: true, index: { name: :dossier }
      t.references :option_pedagogique, foreign_key: true, index: { name: :option }
    end
  end

end
