class AddLibelleToOptionsPedagogiques < ActiveRecord::Migration[5.2]
  def change
    add_column :options_pedagogiques, :libelle, :string

    OptionPedagogique.all.each do |option|
      option.update(libelle: option.nom)
    end
  end
end
