class AddSignatureInscriptionToDossierEleve < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :signature, :boolean, default: false
    add_column :dossier_eleves, :date_signature, :datetime
  end
end
