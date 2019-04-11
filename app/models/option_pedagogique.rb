class OptionPedagogique < ApplicationRecord
  belongs_to :etablissement
  has_and_belongs_to_many :mef
  has_and_belongs_to_many :dossier_eleves
  has_many :montees_pedagogiques

  def self.filtre_par(mef)
    return [] unless mef
    joins(:mef).where(mef: {id: mef.id})
  end
end
