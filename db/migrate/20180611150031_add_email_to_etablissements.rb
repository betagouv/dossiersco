# frozen_string_literal: true

class AddEmailToEtablissements < ActiveRecord::Migration[5.2]

  def change
    add_column :etablissements, :email, :string
  end

end
