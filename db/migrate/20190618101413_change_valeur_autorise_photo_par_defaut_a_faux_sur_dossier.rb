class ChangeValeurAutorisePhotoParDefautAFauxSurDossier < ActiveRecord::Migration[5.2]
  def change
    change_column :dossier_eleves, :autorise_photo_de_classe, :boolean, default: false
  end
end
