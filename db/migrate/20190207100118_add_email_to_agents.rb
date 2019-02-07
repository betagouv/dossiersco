class AddEmailToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :email, :string
  end
end
