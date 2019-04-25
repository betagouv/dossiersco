# frozen_string_literal: true

class CreateTableAbandons < ActiveRecord::Migration[5.1]

  def change
    create_table :abandons do |t|
      t.integer :eleve_id
      t.integer :option_id
    end
  end

end
