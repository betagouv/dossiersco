# frozen_string_literal: true

class Mef < ApplicationRecord

  belongs_to :etablissement
  has_many :mef_options_pedagogiques, dependent: :destroy
  has_many :options_pedagogiques, through: :mef_options_pedagogiques

  validates :libelle, presence: true, uniqueness: { scope: :etablissement }

  def self.niveau_superieur(mef_origine)
    libelle_caracteres = mef_origine.libelle.split("")
    libelle_caracteres[0] = libelle_caracteres[0].to_i - 1
    mef_destination = Mef.find_by(libelle: libelle_caracteres.join, etablissement: mef_origine.etablissement)
    if mef_destination.nil?
      libelle_destination = libelle_caracteres.join.split(" ").first
      mef_destination = Mef.find_by(libelle: libelle_destination, etablissement: mef_origine.etablissement)
    end
    mef_destination
  end

  def self.niveau_precedent(mef_destination)
    first_caractere = mef_destination.libelle[0]
    if first_caractere == "6"
      Mef.find_by(libelle: "CM2", etablissement: mef_destination.etablissement)
    else
      niveau_precedent = first_caractere.to_i + 1
      Mef.find_by(
        libelle: "#{niveau_precedent}#{mef_destination.libelle[1..mef_destination.libelle.length]}",
        etablissement: mef_destination.etablissement
      )
    end
  end

end
