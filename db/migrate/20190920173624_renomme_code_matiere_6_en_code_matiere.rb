class RenommeCodeMatiere6EnCodeMatiere < ActiveRecord::Migration[5.2]
  def change
    rename_column :options_pedagogiques, :code_matiere_6, :code_matiere
  end
end
