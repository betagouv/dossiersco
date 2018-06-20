class RespLegal < ActiveRecord::Base
  belongs_to :dossier_eleve

  def meme_adresse autre_resp_legal
    return false if autre_resp_legal.nil?
    meme_adresse = true
    ["adresse", "code_postal", "ville"].each do |c|
      meme_adresse = meme_adresse && (self[c] == autre_resp_legal[c])
    end
    meme_adresse
  end

  def equivalentes(valeur1, valeur2)
    (valeur1 && valeur1.upcase.gsub(/[[:space:]]/,'')) ==
    (valeur2 && valeur2.upcase.gsub(/[[:space:]]/,''))
  end

  def adresse_inchangee
    equivalentes(adresse, adresse_ant) &&
    equivalentes(ville, ville_ant) &&
    equivalentes(code_postal, code_postal_ant)
  end
end
