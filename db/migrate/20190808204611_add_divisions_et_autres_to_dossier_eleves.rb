class AddDivisionsEtAutresToDossierEleves < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_eleves, :mef_an_dernier, :string
    add_column :dossier_eleves, :division_an_dernier, :string
    add_column :dossier_eleves, :division, :string
  end
end
