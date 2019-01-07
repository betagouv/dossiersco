class Demande < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :option
end

