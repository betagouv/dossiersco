class AddEnvoyerAuxFamillesFromEtablissement < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :envoyer_aux_familles, :boolean, default: false
  end
end
