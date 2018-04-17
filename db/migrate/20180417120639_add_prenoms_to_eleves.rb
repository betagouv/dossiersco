class AddPrenomsToEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :eleves, :prenom_2, :string
    add_column :eleves, :prenom_3, :string
  end
end
