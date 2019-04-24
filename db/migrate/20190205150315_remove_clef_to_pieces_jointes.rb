# frozen_string_literal: true

class RemoveClefToPiecesJointes < ActiveRecord::Migration[5.2]
  def change
    remove_column :pieces_jointes, :clef
  end
end
