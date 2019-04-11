class MonteePedagogique < ActiveRecord::Base
  belongs_to :mef_origine, class_name: 'Mef'
  belongs_to :mef_destination, class_name: 'Mef'
  belongs_to :option_pedagogique

  validate :unique

  def unique
    montee = MonteePedagogique.find_by(mef_destination: self.mef_destination, mef_origine: self.mef_origine, option_pedagogique: self.option_pedagogique)
    if montee.present?
      errors.add(:montee_pedagogique, "existe déjà")
    end
  end
end