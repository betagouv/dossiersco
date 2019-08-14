class SetDefaultValueForCodeModaliteElectToMefOptionsPedagogiques < ActiveRecord::Migration[5.2]
  def change
    change_column :mef_options_pedagogiques, :code_modalite_elect, :string, default: "O", limit: 1
  end
end
