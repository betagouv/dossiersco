class AddEtablissementToMonteesPedagogiques < ActiveRecord::Migration[5.2]
  def change
    add_reference :montees_pedagogiques, :etablissement, foreign_key: true
  end
end
