class TacheImport < ActiveRecord::Base
  belongs_to :etablissement

  def traiter
    self.update(statut: 'en_cours')
    case self.traitement
    when "tout"
      statistiques = import_xls self.url, self.etablissement_id, self.nom_a_importer, self.prenom_a_importer
      self.update(
        statut: 'terminée',
        message: "#{statistiques[:eleves]} élèves importés : "+
        "#{statistiques[:portable]}% de téléphones portables et "+
        "#{statistiques[:email]}% d'emails")
    when "adresses"
      import_adresses self.url, self.etablissement_id
      self.update(statut: 'terminée', message: "Adresses importées")
    end
  end
end
