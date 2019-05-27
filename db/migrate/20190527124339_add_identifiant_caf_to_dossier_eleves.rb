class AddIdentifiantCafToDossierEleves < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_eleves, :identifiant_caf, :string
  end
end
