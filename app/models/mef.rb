class Mef < ApplicationRecord
  belongs_to :etablissement

  validates_presence_of :code, :libelle

  def self.niveau_superieur(mef_origine)
    libelle_caracteres = mef_origine.libelle.split('')
    libelle_caracteres[0] = libelle_caracteres[0].to_i - 1
    find_by(libelle: libelle_caracteres.join, etablissement: mef_origine.etablissement)
  end
end
