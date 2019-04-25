# frozen_string_literal: true

class AddSatisfactionToDossierEleves < ActiveRecord::Migration[5.1]

  def change
    add_column :dossier_eleves, :satisfaction, :integer, default: 0
  end

end
