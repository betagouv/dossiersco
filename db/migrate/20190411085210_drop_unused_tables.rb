class DropUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :abandonnabilites
    drop_table :abandons
    drop_table :active_storage_attachments
    drop_table :active_storage_blobs
    drop_table :demandabilites
    drop_table :demandes
    drop_table :montees
    drop_table :options
  end
end
