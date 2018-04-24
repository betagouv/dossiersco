class AddColonnesToEtablissements < ActiveRecord::Migration[5.1]
  def change
    add_column :etablissements, :adresse, :string
    add_column :etablissements, :ville, :string
    add_column :etablissements, :code_postal, :string
    add_column :etablissements, :dates_permanence, :string
  end
end
