# frozen_string_literal: true

class RemoveColonnesFromContactUrgences < ActiveRecord::Migration[5.1]
  def change
    remove_column :contact_urgences, :adresse
    remove_column :contact_urgences, :code_postal
    remove_column :contact_urgences, :ville
  end
end
