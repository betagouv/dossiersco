class AddExplicationToOptionPedagogique < ActiveRecord::Migration[5.2]
  def change
    add_column :options_pedagogiques, :explication, :text
  end
end
