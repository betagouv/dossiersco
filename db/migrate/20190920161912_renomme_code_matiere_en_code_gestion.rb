class RenommeCodeMatiereEnCodeGestion < ActiveRecord::Migration[5.2]
  def change
    rename_column :options_pedagogiques, :code_matiere, :code_gestion
  end
end
