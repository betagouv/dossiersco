# frozen_string_literal: true

class RenamePieceAttendues < ActiveRecord::Migration[5.2]

  def change
    rename_table :piece_attendues, :pieces_attendues
  end

end
