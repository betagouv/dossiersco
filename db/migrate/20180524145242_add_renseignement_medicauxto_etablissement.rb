class AddRenseignementMedicauxtoEtablissement < ActiveRecord::Migration[5.1]
  def change
    add_column :etablissements, :message_infirmerie, :text
  end
end
