class Mef < ApplicationRecord
  belongs_to :etablissement

  validates_presence_of :etablissement
end
