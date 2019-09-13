class RenameLienAvecEleveToLienDeParenteForContactUrgence < ActiveRecord::Migration[5.2]
  def change
    rename_column :contact_urgences, :lien_avec_eleve, :lien_de_parente
  end
end
