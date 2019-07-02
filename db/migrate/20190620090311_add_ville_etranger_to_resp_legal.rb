class AddVilleEtrangerToRespLegal < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :ville_etrangere, :string
  end
end
