class AddCommuneInseeNaissanceToEleve < ActiveRecord::Migration[5.2]
  def change
    add_column :eleves, :commune_insee_naissance, :string
  end
end
