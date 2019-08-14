class AddCodeModaliteElectToMefOptionPedagogique < ActiveRecord::Migration[5.2]
  def change
    add_column :mef_options_pedagogiques, :code_modalite_elect, :string
  end
end
