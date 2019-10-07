# frozen_string_literal: true

rl_sans_adresse = RespLegal.joins(:dossier_eleve).where("dossier_eleves.etat = 'validé'").where(adresse: [nil, "", "Inconnue"])

puts "Nb de responsables légaux sans adresse: #{rl_sans_adresse.count}"

rl_sans_adresse.group("dossier_eleves.etablissement_id").count.each do |ets_id, count|
  etablissement = Etablissement.find(ets_id)
  puts "#{etablissement.nom} (uai: #{etablissement.uai}) : #{count}"
end
