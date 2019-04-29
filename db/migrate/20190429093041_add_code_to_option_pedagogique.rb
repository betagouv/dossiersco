# frozen_string_literal: true

class AddCodeToOptionPedagogique < ActiveRecord::Migration[5.2]

  def change
    add_column :options_pedagogiques, :code_matiere, :string
  end

end
