class Agent < ActiveRecord::Base
  belongs_to :etablissement
  has_secure_password validations: false

  validates :password_digest, presence: true, if: -> { self.jeton.nil? }
  validates :identifiant, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def nom_complet
    nom_complet = [prenom, nom].join(' ').strip
    nom_complet.present? ? nom_complet : email
  end
end
