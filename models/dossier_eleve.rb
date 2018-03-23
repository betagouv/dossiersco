class DossierEleve < ActiveRecord::Base
  belongs_to :eleve
  has_many :resp_legals
  has_one :contact_urgence
end