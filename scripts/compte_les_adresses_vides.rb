# frozen_string_literal: true

if ARGV.empty?
  puts "#{$PROGRAM_NAME} nom_etablissement"
else
  etablissement = Etablissement.select { |e| e.nom =~ /#{ARGV[0]}/ }.first
  puts "#{etablissement.nom}, id: #{etablissement.id}"
  puts DossierEleve.select { |d| d.etablissement_id == etablissement.id && d.etat == "validé" }
                   .map(&:resp_legal).flatten.select { |r| r.adresse.strip == "" }.count
end
