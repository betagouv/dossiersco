class AddDemandeCafToEtablissement < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :demande_caf, :boolean, default: false
  end
end
