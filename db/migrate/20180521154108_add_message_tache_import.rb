# frozen_string_literal: true

class AddMessageTacheImport < ActiveRecord::Migration[5.1]
  def change
    add_column :tache_imports, :message, :string
  end
end
