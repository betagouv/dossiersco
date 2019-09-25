class AddEleveFieldsToDossierEleve < ActiveRecord::Migration[5.2]
  def change

    change_table :dossier_eleves do |t|
      t.string "identifiant"
      t.string "prenom"
      t.string "nom"
      t.string "sexe"
      t.string "ville_naiss"
      t.string "nationalite"
      t.string "classe_ant"
      t.string "date_naiss"
      t.string "pays_naiss"
      t.string "niveau_classe_ant"
      t.string "prenom_2"
      t.string "prenom_3"
      t.string "commune_insee_naissance"
      t.string "id_prv_ele"
    end

  end
end
