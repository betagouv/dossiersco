class Agent < ActiveRecord::Base
  belongs_to :etablissement
  has_secure_password

  validates :identifiant, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def nom_complet
    nom_complet = [prenom, nom].join(' ').strip
    nom_complet.present? ? nom_complet : email
  end
end
