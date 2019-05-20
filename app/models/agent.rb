# frozen_string_literal: true

class Agent < ActiveRecord::Base

  belongs_to :etablissement
  has_secure_password validations: false

  validates :password_digest, presence: true, if: -> { jeton.nil? }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :pour_etablissement, lambda { |etablissement|
    super_admins = ENV["SUPER_ADMIN"].present? ? ENV["SUPER_ADMIN"].delete(" ").split(",") : [""]
    where(etablissement: etablissement).where.not("email IN (?)", super_admins)
  }

  def nom_complet
    nom_complet = [prenom, nom].join(" ").strip
    nom_complet.present? ? nom_complet : email
  end

end
