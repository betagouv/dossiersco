class AddDateValidationAgentToDossierEleves < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_eleves, :date_validation_agent, :datetime
  end
end
