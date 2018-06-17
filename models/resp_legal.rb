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
end
