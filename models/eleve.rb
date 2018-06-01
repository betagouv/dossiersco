class Eleve < ActiveRecord::Base
  has_one :dossier_eleve
  has_and_belongs_to_many :option
  has_many :demande
  belongs_to :montee
end
