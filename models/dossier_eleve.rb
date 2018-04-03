class DossierEleve < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :etablissement
  has_many :resp_legal
  has_one :contact_urgence
end
