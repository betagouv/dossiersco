class AddCommentaireToDossierEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :commentaire, :text
  end
end
