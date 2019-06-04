class AddTimeStampsToRegimesSortie < ActiveRecord::Migration[5.2]
  def change
    add_column :regimes_sortie, :created_at, :datetime
    add_column :regimes_sortie, :updated_at, :datetime
  end
end
