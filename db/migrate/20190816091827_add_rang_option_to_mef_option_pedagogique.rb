class AddRangOptionToMefOptionPedagogique < ActiveRecord::Migration[5.2]
  def change
    add_column :mef_options_pedagogiques, :rang_option, :integer
  end
end
