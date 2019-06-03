class AddOuverteInscriptionToMefOptionPedagogique < ActiveRecord::Migration[5.2]
  def change
    add_column :mef_options_pedagogiques, :ouverte_inscription, :boolean, default: true
  end
end
