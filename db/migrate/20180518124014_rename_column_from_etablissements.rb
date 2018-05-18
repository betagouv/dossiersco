class RenameColumnFromEtablissements < ActiveRecord::Migration[5.1]
  def change
    rename_column :etablissements, :dates_permanence, :message_permanence
  end
end
