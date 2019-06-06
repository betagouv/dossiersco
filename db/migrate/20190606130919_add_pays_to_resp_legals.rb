class AddPaysToRespLegals < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :pays, :string, default: "FRA"
  end
end
