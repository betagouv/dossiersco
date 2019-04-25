# frozen_string_literal: true

class RemoveSituationEmploiEtEnfantsScolarises < ActiveRecord::Migration[5.2]

  def change
    remove_column :resp_legals, :situation_emploi
    remove_column :resp_legals, :enfants_a_charge_secondaire
  end

end
