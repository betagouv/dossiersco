# frozen_string_literal: true

def genre(prenom)
  [1,2].each do |genre|
    return genre if `grep -i "#{genre};#{prenom}" lib/nat2018.csv`.present?
  end

  nil
end

ContactUrgence.where(civilite: nil).each do |contact_sans_civilite|
  prenom = contact_sans_civilite.prenom&.upcase || ""

  puts genre(prenom)
  contact_sans_civilite.update(civilite: genre(prenom))
end
