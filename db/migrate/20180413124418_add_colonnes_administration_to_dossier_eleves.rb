# frozen_string_literal: true

class AddColonnesAdministrationToDossierEleves < ActiveRecord::Migration[5.1]
  def change
    add_column :dossier_eleves, :demi_pensionnaire, :boolean, default: false
    add_column :dossier_eleves, :autorise_sortie, :boolean, default: false
    add_column :dossier_eleves, :renseignements_medicaux, :boolean, default: false
    add_column :dossier_eleves, :autorise_photo_de_classe, :boolean, default: true
  end
end
