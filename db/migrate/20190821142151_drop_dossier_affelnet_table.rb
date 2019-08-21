class DropDossierAffelnetTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :dossiers_affelnet
  end
end
