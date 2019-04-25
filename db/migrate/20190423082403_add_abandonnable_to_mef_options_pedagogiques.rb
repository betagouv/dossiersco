# frozen_string_literal: true

class AddAbandonnableToMefOptionsPedagogiques < ActiveRecord::Migration[5.2]

  def change
    add_column :mef_options_pedagogiques, :abandonnable, :boolean, default: true
  end

end
