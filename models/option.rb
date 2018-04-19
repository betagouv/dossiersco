class Option < ActiveRecord::Base
  belongs_to :etablissement
  validates_uniqueness_of :nom, scope: :etablissement_id
  has_and_belongs_to_many :eleve
end
