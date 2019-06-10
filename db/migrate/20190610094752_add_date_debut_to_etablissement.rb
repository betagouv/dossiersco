class AddDateDebutToEtablissement < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :date_debut, :date
  end
end
