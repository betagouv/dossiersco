# frozen_string_literal: true

class AddChangementAdresse < ActiveRecord::Migration[5.1]

  def change
    add_column :resp_legals, :changement_adresse, :boolean, default: false
  end

end
