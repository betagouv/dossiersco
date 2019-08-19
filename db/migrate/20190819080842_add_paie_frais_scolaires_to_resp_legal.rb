class AddPaieFraisScolairesToRespLegal < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :paie_frais_scolaires, :boolean
  end
end
