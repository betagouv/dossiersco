class AddObligatoireToPieceDemandees < ActiveRecord::Migration[5.1]
  def change
    add_column :piece_attendues, :obligatoire, :boolean, default: false
  end
end
