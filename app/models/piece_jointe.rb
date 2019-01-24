class PieceJointe < ActiveRecord::Base
  belongs_to :dossier_eleve
  belongs_to :piece_attendue

  delegate :obligatoire, :code, :nom, :explication, to: :piece_attendue

  has_one_attached :fichier

  def ext
    self.clef.match(/(\w+$)/im)[1].downcase
  end
end
