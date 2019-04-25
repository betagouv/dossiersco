# frozen_string_literal: true

class AddJetonToAgents < ActiveRecord::Migration[5.2]

  def change
    add_column :agents, :jeton, :string
  end

end
