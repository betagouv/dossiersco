# frozen_string_literal: true

uai = ARGV[0]
unless uai.present?
  puts "veuillez fournir l'UAI de l'établissement (exemple : 0770002J)"
  return
end

puts Etablissement.find_by(uai: uai).dossier_eleve.map(&:piece_jointe).flatten.map(&:fichiers).flatten.map(&:path).to_yaml


