# frozen_string_literal: true

class AddEtablissementToOptionsPedagogiques < ActiveRecord::Migration[5.2]
  def change
    add_reference :options_pedagogiques, :etablissement, foreign_key: true
  end
end
