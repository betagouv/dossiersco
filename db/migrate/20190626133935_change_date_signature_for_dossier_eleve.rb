class ChangeDateSignatureForDossierEleve < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_eleves, :date_signature, :date_validation_famille
  end
end
