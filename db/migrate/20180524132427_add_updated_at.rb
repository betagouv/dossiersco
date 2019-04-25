# frozen_string_literal: true

class AddUpdatedAt < ActiveRecord::Migration[5.1]

  def change
    add_column :contact_urgences, :updated_at, :datetime
    add_column :etablissements, :updated_at, :datetime
    add_column :resp_legals, :updated_at, :datetime
    add_column :tache_imports, :updated_at, :datetime
  end

end
