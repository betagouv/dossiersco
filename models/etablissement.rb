class Etablissement < ActiveRecord::Base
  has_many :dossier_eleves
  has_many :agents
end
