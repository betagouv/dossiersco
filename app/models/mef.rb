class Mef < ApplicationRecord
  belongs_to :etablissement

  validates_presence_of :code, :libelle

  def self.niveau_supérieur(mef_origine)
    code_splitté = mef_origine.code.split('').map(&:to_i)
    nouveau_code = code_splitté[0..1]
    nouveau_code << code_splitté[2] + 1
    nouveau_code.concat(code_splitté[3..])
    find_by(code: nouveau_code.join('').to_s, etablissement: mef_origine.etablissement)
  end
end
