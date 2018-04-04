class AddEtatFichiersDossierEleve < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :etat_photo_identite, :string
    add_column :dossier_eleves, :etat_assurance_scolaire, :string
    add_column :dossier_eleves, :etat_jugement_garde_enfant, :string
  end
end
