class AddGroupeToOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :groupe, :string
  end
end
