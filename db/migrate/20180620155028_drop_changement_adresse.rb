# frozen_string_literal: true

class DropChangementAdresse < ActiveRecord::Migration[5.2]
  def change
    remove_column :resp_legals, :changement_adresse
  end
end
