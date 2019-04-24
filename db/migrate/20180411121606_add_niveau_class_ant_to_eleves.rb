# frozen_string_literal: true

class AddNiveauClassAntToEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :eleves, :niveau_classe_ant, :string
  end
end
