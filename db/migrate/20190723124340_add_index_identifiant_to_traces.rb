class AddIndexIdentifiantToTraces < ActiveRecord::Migration[5.2]
  def self.up
    add_index :traces, :identifiant, :name=>'identifiant_index'
  end

  def self.down
    remove_index :traces, 'identifiant_index'
  end
end
