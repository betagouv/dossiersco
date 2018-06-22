class CreateMessageEmis < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :dossier_eleve_id
      t.string    :categorie
      t.string    :contenu
      t.string    :etat
      t.string    :resultat
      t.datetime  :created_at
    end
  end
end
