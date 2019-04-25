# frozen_string_literal: true

class CreateOptionsPedagogiques < ActiveRecord::Migration[5.2]

  def change
    create_table :options_pedagogiques do |t|
      t.string :nom
      t.string :groupe
      t.boolean :obligatoire, default: false
      t.timestamps
    end
  end

end
