class ChangeJobKlassEnTypeFichier < ActiveRecord::Migration[5.2]
  def change
    rename_column :tache_imports, :job_klass, :type_fichier
  end
end
