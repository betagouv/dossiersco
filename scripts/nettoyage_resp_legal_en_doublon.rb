# frozen_string_literal: true

uai = ARGV[0]
unless uai.present?
  puts "veuillez fournir l'UAI de l'établissement (exemple : 0770002J)"
  return
end

liste = []

Etablissement.find_by(uai: uai).dossier_eleve.each do |dossier|
  next if dossier.resp_legal.count != 2
  next unless dossier.resp_legal.first.nom.casecmp(dossier.resp_legal.last.nom).zero?
  next unless dossier.resp_legal.first.prenom.casecmp(dossier.resp_legal.last.prenom).zero?
  next unless dossier.resp_legal.first.adresse.casecmp(dossier.resp_legal.last.adresse).zero?

  liste << dossier.id
  puts "Dossier avec RespLegal en doublon ? : "
  puts " --> #{dossier.resp_legal.first.inspect}"
  puts " --> #{dossier.resp_legal.last.inspect}"
end

puts liste

DossierEleve.where("id in (?)", liste).sample.resp_legal
