class RemoveDemarcheToDossierEleve < ActiveRecord::Migration[5.2]
  def change
    remove_column :dossier_eleves, :demarche
  end
end
