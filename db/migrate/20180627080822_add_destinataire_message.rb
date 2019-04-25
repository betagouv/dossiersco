# frozen_string_literal: true

class AddDestinataireMessage < ActiveRecord::Migration[5.2]

  def change
    add_column :messages, :destinataire, :string, default: "rl1"
  end

end
