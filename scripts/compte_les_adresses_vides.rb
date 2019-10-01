# frozen_string_literal: true

if ARGV.empty?
  puts "#{$PROGRAM_NAME} id_etablissement"
else
  puts ARGV[0].to_s
  DossierEleve.select { |d| d.etablissement_id == ARGV[0] && d.etat == "Validé" }.map(&:resp_legal).flatten.select { |r| r.adresse.strip == "" }.count
end
