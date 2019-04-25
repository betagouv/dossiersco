# frozen_string_literal: true

class AddMefToDossierEleves < ActiveRecord::Migration[5.2]

  def change
    add_reference :dossier_eleves, :mef_origine, foreign_key: { to_table: :mef }
    add_reference :dossier_eleves, :mef_destination, foreign_key: { to_table: :mef }
  end

end
