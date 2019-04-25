# frozen_string_literal: true

class AddTraces < ActiveRecord::Migration[5.2]

  def change
    create_table :traces do |t|
      t.string    :identifiant
      t.string    :categorie
      t.string    :page_demandee
      t.string    :adresse_ip
      t.datetime  :created_at
    end
  end

end
