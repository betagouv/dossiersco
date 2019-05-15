class AddMotAccueilToEtablissements < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :mot_accueil, :string
  end
end
