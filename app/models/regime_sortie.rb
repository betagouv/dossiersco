# frozen_string_literal: true

class RegimeSortie < ApplicationRecord

  belongs_to :etablissement
  has_many :dossier_eleves

  validates :nom, presence: true, allow_blank: false

end
