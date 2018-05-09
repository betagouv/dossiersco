class PieceAttendue < ActiveRecord::Base
  belongs_to :etablissement
  has_many :piece_jointe
end
