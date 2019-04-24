# frozen_string_literal: true

class CreateOptionsDemandees < ActiveRecord::Migration[5.1]
  def change
    create_table :demandes do |t|
      t.integer :eleve_id
      t.integer :option_id
    end
  end
end
