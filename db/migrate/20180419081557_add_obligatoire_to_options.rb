# frozen_string_literal: true

class AddObligatoireToOptions < ActiveRecord::Migration[5.1]

  def change
    add_column :options, :obligatoire, :boolean, default: false
  end

end
