class AddPrioriteToRespLegals < ActiveRecord::Migration[5.1]
  def change
    add_column :resp_legals, :priorite, :integer
  end
end
