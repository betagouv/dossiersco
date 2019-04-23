# frozen_string_literal: true

class OptionPedagogique < ApplicationRecord
  belongs_to :etablissement
  has_and_belongs_to_many :dossier_eleves
  has_many :mef_options_pedagogiques
  has_many :mef, through: :mef_options_pedagogiques

  def self.filtre_par(mef)
    return [] unless mef

    joins(:mef).where(mef: { id: mef.id })
  end

  def abandonnable?(mef)
    self.mef_options_pedagogiques.find_by(mef: mef).abandonnable
  end
end
