class AddReglementDemiPensionToEtablissement < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :reglement_demi_pension, :string
  end
end
