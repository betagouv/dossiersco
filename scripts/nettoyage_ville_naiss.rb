# frozen_string_literal: true

Eleve.where("ville_naiss is not null").each { |e| e.update(ville_naiss: e.ville_naiss.upcase) }

Eleve.where("ville_naiss like '%-%'").each { |e| e.update(ville_naiss: e.ville_naiss.tr("-", " ")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%É%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/É/, "E")) }

Eleve.where("ville_naiss like '%È%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/È/, "E")) }

Eleve.where("ville_naiss like '%Î%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Î/, "I")) }

Eleve.where("ville_naiss like '%Ç%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Ç/, "C")) }

Eleve.where(ville_naiss: "PARIS 01E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 01") }
Eleve.where(ville_naiss: "PARIS 02E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 02") }
Eleve.where(ville_naiss: "PARIS 03E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 03") }
Eleve.where(ville_naiss: "PARIS 04E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 04") }
Eleve.where(ville_naiss: "PARIS 05E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 05") }
Eleve.where(ville_naiss: "PARIS 06E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 06") }
Eleve.where(ville_naiss: "PARIS 07E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 07") }
Eleve.where(ville_naiss: "PARIS 08E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 08") }
Eleve.where(ville_naiss: "PARIS 09E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 09") }
Eleve.where(ville_naiss: "PARIS 10E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 10") }
Eleve.where(ville_naiss: "PARIS 11E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 11") }
Eleve.where(ville_naiss: "PARIS 12E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 12") }
Eleve.where(ville_naiss: "PARIS 13E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 13") }
Eleve.where(ville_naiss: "PARIS 14E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 14") }
Eleve.where(ville_naiss: "PARIS 15E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 15") }
Eleve.where(ville_naiss: "PARIS 16E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 16") }
Eleve.where(ville_naiss: "PARIS 17E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 17") }
Eleve.where(ville_naiss: "PARIS 18E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 18") }
Eleve.where(ville_naiss: "PARIS 19E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 19") }
Eleve.where(ville_naiss: "PARIS 20E  ARRONDISSEMENT").each { |e| e.update(ville_naiss: "PARIS 20") }

communes = {}
CSV.foreach("app/services/laposte_hexasmal.csv", col_sep: ";") do |row|
  communes[row[1]] = row[0]
end

Eleve.all.each do |eleve|
  eleve.update(commune_insee_naissance: communes[eleve.ville_naiss])
end
