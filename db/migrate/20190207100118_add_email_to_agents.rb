# frozen_string_literal: true

class AddEmailToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :email, :string
  end
end
