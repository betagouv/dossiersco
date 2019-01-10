class Option < ActiveRecord::Base
  has_and_belongs_to_many :eleve
  def nom_et_info
    self.nom + (self.info.present? ? " #{self.info}" : "")
  end
end
