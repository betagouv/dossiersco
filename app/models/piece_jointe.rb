class PieceJointe < ActiveRecord::Base
  belongs_to :dossier_eleve
  belongs_to :piece_attendue

  delegate :obligatoire, :code, :nom, :explication, to: :piece_attendue

  mount_uploader :fichier, FichierUploader

  ETATS = { soumis: 'soumis', valide: 'valide', invalide: 'invalide' }

  validates :etat, inclusion: { in: ETATS.values }

  def ext
    self.clef.match(/(\w+$)/im)[1].downcase
  end

  def nom_etablissement
    dossier_eleve.etablissement.nom if dossier_eleve.etablissement
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
