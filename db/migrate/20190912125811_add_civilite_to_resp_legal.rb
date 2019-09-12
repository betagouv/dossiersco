class AddCiviliteToRespLegal < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :civilite, :string
  end
end
