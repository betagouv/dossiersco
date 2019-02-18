class AddJetonToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :jeton, :string
  end
end
