class CreateDossierElevesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :dossier_eleves do |t|
      t.belongs_to :eleve, foreign_key: true
      t.string :demarche
      t.datetime :created_at
      t.datetime :updated_at
    end

  end
end
