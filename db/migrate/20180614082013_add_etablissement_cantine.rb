# frozen_string_literal: true

class AddEtablissementCantine < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :gere_demi_pension, :boolean, default: false
  end
end
