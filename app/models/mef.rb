class Mef < ApplicationRecord
  belongs_to :etablissement
  has_and_belongs_to_many :options_pedagogiques

  validates :code, presence: true, uniqueness: {scope: :etablissement}
  validates :libelle, presence: true, uniqueness: {scope: :etablissement}

  def self.niveau_superieur(mef_origine)
    libelle_caracteres = mef_origine.libelle.split('')
    libelle_caracteres[0] = libelle_caracteres[0].to_i - 1
    find_by(libelle: libelle_caracteres.join, etablissement: mef_origine.etablissement)
  end
end
