# frozen_string_literal: true

uai = ARGV[0]
unless uai.present?
  puts "veuillez fournir l'UAI de l'établissement (exemple : 0770002J)"
  return
end
etablissement = Etablissement.find_by(uai: uai)

dossiers = etablissement.dossier_eleve.joins(:resp_legal).select {|d| d.resp_legal.map { |r| (r.lien_de_parente + r.prenom + r.nom).downcase }.uniq.count == 1 }

dossiers.each do |dossier|
  next if dossier.resp_legal.count == 1
  print "#{dossier.id}-#{dossier.eleve.prenom}-#{dossier.eleve.nom}"

  premier_responsable = dossier.resp_legal.find_by(priorite: 1)
  deuxieme_responsable = dossier.resp_legal.find_by(priorite: 2)

  attributs = [:prenom, :nom, :tel_personnel, :tel_professionnel, :tel_portable, :profession, :email, :adresse, :ville, :code_postal, :enfants_a_charge]

  supprimer = attributs.map do |attr|
    deuxieme_responsable.send(attr).present? && premier_responsable.send(attr).downcase == deuxieme_responsable.send(attr).downcase
  end

  if supprimer.uniq == [true]
    p " supprime #{premier_responsable.id}-#{premier_responsable.prenom}-#{premier_responsable.nom}"
  end
  puts " "
end

