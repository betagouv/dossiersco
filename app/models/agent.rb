class Agent < ActiveRecord::Base
  belongs_to :etablissement
  has_secure_password

  validates :identifiant, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
