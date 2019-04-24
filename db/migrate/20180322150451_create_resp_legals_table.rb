# frozen_string_literal: true

class CreateRespLegalsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :resp_legals do |t|
      t.integer :dossier_eleve_id
      t.string :lien_de_parente
      t.string :prenom
      t.string :nom
      t.string :adresse
      t.string :code_postal
      t.string :ville
      t.string :tel_principal
      t.string :tel_secondaire
      t.string :email
      t.string :situation_emploi
      t.string :profession
      t.integer :enfants_a_charge
      t.integer :enfants_a_charge_secondaire
      t.boolean :communique_info_parents_eleves
    end
  end
end
