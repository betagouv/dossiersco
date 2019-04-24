# frozen_string_literal: true

class AddSignataireEtablissement < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :signataire, :string, default: ''
  end
end
