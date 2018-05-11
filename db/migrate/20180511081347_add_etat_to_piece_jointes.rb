class AddEtatToPieceJointes < ActiveRecord::Migration[5.1]
  def change
    add_column :piece_jointes, :etat, :string
    remove_column :dossier_eleves, :etat_photo_identite
    remove_column :dossier_eleves, :etat_assurance_scolaire
    remove_column :dossier_eleves, :etat_jugement_garde_enfant
    remove_column :dossier_eleves, :photo_identite
    remove_column :dossier_eleves, :assurance_scolaire
    remove_column :dossier_eleves, :jugement_garde_enfant
  end
end
