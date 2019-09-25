# frozen_string_literal: true

class Eleve < ActiveRecord::Base

  has_one :dossier_eleve, dependent: :destroy
  has_many :demande
  has_many :abandon
  belongs_to :montee, required: false
  delegate :email_resp_legal_1, to: :dossier_eleve

  def self.par_authentification(identifiant, jour, mois, annee)
    identifiant = identifiant.gsub(/[^[:alnum:]]/, "").upcase
    date_naissance = "#{annee}-#{format('%02d', mois.to_i)}-#{format('%02d', jour.to_i)}"
    find_by(identifiant: identifiant, date_naiss: date_naissance)
  end

  #  TODO: déplacer cette méthode dans dossier
  def self.creation_ou_retrouve_par(identifiant)
    find_or_initialize_by(identifiant: identifiant.gsub(/[^[:alnum:]]/, "").upcase)
  end

end
