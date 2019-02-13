class ChangeTacheImport < ActiveRecord::Migration[5.2]
  def change
    remove_column :tache_imports, :url, :string
    remove_column :tache_imports, :nom_a_importer, :string
    remove_column :tache_imports, :prenom_a_importer, :string
    remove_column :tache_imports, :message
    add_column :tache_imports, :job_klass, :string
  end
end
