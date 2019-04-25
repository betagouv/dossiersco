# frozen_string_literal: true

class PieceAttendue < ActiveRecord::Base

  belongs_to :etablissement
  has_many :piece_jointe, dependent: :destroy

end
