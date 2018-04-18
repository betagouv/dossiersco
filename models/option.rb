class Option < ActiveRecord::Base
  belongs_to :etablissement
  validates_uniqueness_of :nom, scope: :etablissement_id
end
