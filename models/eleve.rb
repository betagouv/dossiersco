class Eleve < ActiveRecord::Base
  has_one :dossier_eleve
end