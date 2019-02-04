class PieceJointe < ActiveRecord::Base
  belongs_to :dossier_eleve
  belongs_to :piece_attendue

  delegate :obligatoire, :code, :nom, :explication, to: :piece_attendue

  mount_uploader :fichier, FichierUploader

  def ext
    self.clef.match(/(\w+$)/im)[1].downcase
  end

  def nom_etablissement
    dossier_eleve.etablissement.nom
  end
end
