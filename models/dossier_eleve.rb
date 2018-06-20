class DossierEleve < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :etablissement
  has_many :resp_legal
  has_one :contact_urgence
  has_many :piece_jointe

  def resp_legal_1
    self.resp_legal.find {|r| r.priorite == 1}
  end

  def resp_legal_2
    self.resp_legal.find {|r| r.priorite == 2}
  end

  def allocataire
    enfants = self.resp_legal.first.enfants_a_charge || 0
    enfants > 1
  end
end
