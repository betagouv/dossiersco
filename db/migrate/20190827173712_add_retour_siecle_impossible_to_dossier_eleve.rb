class AddRetourSiecleImpossibleToDossierEleve < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_eleves, :retour_siecle_impossible, :string
  end
end
