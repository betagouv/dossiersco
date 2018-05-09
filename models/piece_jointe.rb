class PieceJointe < ActiveRecord::Base
  belongs_to :dossier_eleve
  belongs_to :piece_attendue
end
