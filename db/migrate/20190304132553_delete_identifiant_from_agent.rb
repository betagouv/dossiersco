class DeleteIdentifiantFromAgent < ActiveRecord::Migration[5.2]
  def change
    remove_column :agents, :identifiant
  end
end
