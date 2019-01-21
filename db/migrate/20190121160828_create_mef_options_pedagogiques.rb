class CreateMefOptionsPedagogiques < ActiveRecord::Migration[5.2]
  def change
    create_table :mef_options_pedagogiques do |t|
      t.references :mef
      t.references :options_pedagogiques
    end
  end
end
