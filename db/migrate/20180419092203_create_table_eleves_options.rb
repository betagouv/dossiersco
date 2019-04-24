# frozen_string_literal: true

class CreateTableElevesOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :eleves_options do |t|
      t.integer :eleve_id
      t.integer :option_id
    end
    remove_column :eleves, :lv2, :string
  end
end
