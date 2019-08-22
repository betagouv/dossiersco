class AddResponsablesUploadedToEtablissements < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :responsables_uploaded, :boolean, default: false
  end
end
