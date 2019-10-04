class AddCiviliteToContactUrgence < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_urgences, :civilite, :int
  end
end
