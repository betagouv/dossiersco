class CreateAbandonnabilites < ActiveRecord::Migration[5.1]
  def change
    create_table :abandonnabilites do |t|
      t.integer :montee_id
      t.integer :option_id
    end
  end
end
