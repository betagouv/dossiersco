class TacheImport < ActiveRecord::Base
  belongs_to :etablissement

  mount_uploader :fichier, ImportUploader

  STATUTS = { en_attente: 'en attente', en_traitement: 'en traitement', terminee: 'terminée', en_erreur: 'en erreur' }

  validates :statut, inclusion: { in: STATUTS.values }
end
