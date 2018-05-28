class Option < ActiveRecord::Base
  belongs_to :etablissement
  has_and_belongs_to_many :eleve
end

class Demande < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :option
end
