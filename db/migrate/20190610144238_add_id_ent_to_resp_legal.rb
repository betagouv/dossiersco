class AddIdEntToRespLegal < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :id_ent, :integer
  end
end
