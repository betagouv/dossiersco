class SupprimeChampTraitement < ActiveRecord::Migration[5.2]
  def change
    remove_column :tache_imports, :traitement
  end
end
