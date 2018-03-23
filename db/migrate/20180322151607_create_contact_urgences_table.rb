class CreateContactUrgencesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_urgences do |t|
      t.integer :dossier_eleve_id
      t.string :lien_avec_eleve
      t.string :prenom
      t.string :nom
      t.string :adresse
      t.string :code_postal
      t.string :ville
      t.string :tel_principal
      t.string :tel_secondaire
    end
  end
end
