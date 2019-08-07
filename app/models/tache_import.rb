# frozen_string_literal: true

class TacheImport < ActiveRecord::Base

  belongs_to :etablissement

  mount_uploader :fichier, ImportUploader

  STATUTS = { en_attente: "en attente", en_traitement: "en traitement", terminee: "terminée", en_erreur: "en erreur" }.freeze

  validates :statut, inclusion: { in: STATUTS.values }

  def import_nomenclature?
    type_fichier == "nomenclature"
  end

  def import_responsables?
    type_fichier == "responsables"
  end

end
