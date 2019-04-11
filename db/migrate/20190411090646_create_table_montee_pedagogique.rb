class CreateTableMonteePedagogique < ActiveRecord::Migration[5.2]
  def change
    create_table :montees_pedagogiques do |t|
      t.references :option_pedagogique, foreign_key: true
      t.boolean :abandonnable
    end
    add_reference :montees_pedagogiques, :mef_origine, foreign_key: {to_table: :mef}
    add_reference :montees_pedagogiques, :mef_destination, foreign_key: {to_table: :mef}
  end
end
