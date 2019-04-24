# frozen_string_literal: true

class RenameTablePieceJointes < ActiveRecord::Migration[5.2]
  def change
    rename_table :piece_jointes, :pieces_jointes
  end
end
