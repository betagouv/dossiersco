class AddRegimeSortieToDossierEleves < ActiveRecord::Migration[5.2]
  def change
    add_reference :dossier_eleves, :regime_sortie, foreign_key: true
  end
end
