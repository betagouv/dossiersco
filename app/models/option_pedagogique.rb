class OptionPedagogique < ApplicationRecord
  has_and_belongs_to_many :mef
  has_and_belongs_to_many :dossier_eleves
end
