# frozen_string_literal: true

class CreateMef < ActiveRecord::Migration[5.2]
  def change
    create_table :mef do |t|
      t.string :libelle
      t.string :code
      t.references :etablissement

      t.timestamps
    end
  end
end
