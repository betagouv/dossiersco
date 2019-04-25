# frozen_string_literal: true

class AddUaiToEtablissement < ActiveRecord::Migration[5.2]

  def change
    add_column :etablissements, :uai, :string
  end

end
