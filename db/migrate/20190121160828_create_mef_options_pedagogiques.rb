# frozen_string_literal: true

class CreateMefOptionsPedagogiques < ActiveRecord::Migration[5.2]
  def change
    create_table :mef_options_pedagogiques do |t|
      t.references :mef
      t.references :option_pedagogique
    end
  end
end
