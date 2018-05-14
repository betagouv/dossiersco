class Option < ActiveRecord::Base
  belongs_to :etablissement
  validates_uniqueness_of :nom, scope: :niveau_debut
  has_and_belongs_to_many :eleve
end
