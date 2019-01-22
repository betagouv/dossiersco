class AddPasswordDigestToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :password_digest, :string
  end
end
