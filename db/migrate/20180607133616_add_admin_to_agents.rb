# frozen_string_literal: true

class AddAdminToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :admin, :boolean
  end
end
