class AddInfoOption < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :info, :string
  end
end
