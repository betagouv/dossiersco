# frozen_string_literal: true

uai = ARGV[0]
unless uai.present?
  puts "veuillez fournir l'UAI de l'établissement (exemple : 0770002J)"
  return
end

liste = []

Etablissement.find_by(uai: uai).dossier_eleve.each do |dossier|
  liste << {
    "ine" => dossier.eleve.identifiant,
    "prenom" => dossier.eleve.prenom,
    "nom" => dossier.eleve.nom,
    "fichiers" => dossier.piece_jointe.select { |pj| pj.etat == PieceJointe::ETATS[:valide] }.map(&:fichiers).flatten.map(&:path)
  }
end

puts liste.to_yaml
