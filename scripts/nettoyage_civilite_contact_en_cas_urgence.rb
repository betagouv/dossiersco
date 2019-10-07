# frozen_string_literal: true

def genre(prenom)
  [1, 2].each do |genre|
    return genre if `grep -i "#{genre};#{prenom}" #{Rails.root}/lib/prenoms.csv`.present?
  end

  nil
end

ContactUrgence.where(civilite: nil).each do |contact_sans_civilite|
  prenom = contact_sans_civilite.prenom&.upcase&.strip&.tr(" ", "-") || ""

  puts genre(prenom)
  prenom_decoupe = prenom.split("-")
  if prenom_decoupe.include?("ET") ||
     prenom_decoupe.include?("OU") ||
     prenom_decoupe.include?("&") ||
     prenom_decoupe.include?("/")
    contact_sans_civilite.update(civilite: genre(prenom_decoupe[0]))
  else
    contact_sans_civilite.update(civilite: genre(prenom))
  end
end
