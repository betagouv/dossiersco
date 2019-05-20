# frozen_string_literal: true

class PieceJointe < ActiveRecord::Base

  belongs_to :dossier_eleve
  belongs_to :piece_attendue

  delegate :obligatoire, :code, :nom, :explication, to: :piece_attendue

  mount_uploaders :fichiers, FichierUploader

  ETATS = { soumis: "soumis", valide: "valide", invalide: "invalide" }.freeze

  validates :etat, inclusion: { in: ETATS.values }

  def ext
    clef.match(/(\w+$)/im)[1].downcase
  end

  def nom_etablissement
    dossier_eleve.etablissement&.nom
  end

  def valide!
    update!(etat: ETATS[:valide])
  end

  def invalide!
    update!(etat: ETATS[:invalide])
  end

  def soumet!
    update!(etat: ETATS[:soumis])
  end

end
