class AddContinuerDossierscoToDossierEleves < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_eleves, :continuer_dossiersco, :boolean
  end
end
