class CreateEtablissementsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :etablissements do |t|
      t.string :nom
      t.string :date_limite
    end
    add_column :dossier_eleves, :etablissement_id, :integer
  end
end
