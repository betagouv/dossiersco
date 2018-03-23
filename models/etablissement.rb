class Etablissement < ActiveRecord::Base
  has_many :dossier_eleve
end
