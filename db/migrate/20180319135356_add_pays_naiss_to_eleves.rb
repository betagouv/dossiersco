# frozen_string_literal: true

class AddPaysNaissToEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :eleves, :pays_naiss, :string
  end
end
