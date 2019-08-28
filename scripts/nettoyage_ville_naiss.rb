# frozen_string_literal: true

Eleve.where("ville_naiss is not null").each { |e| e.update(ville_naiss: e.ville_naiss.upcase) }

Eleve.where("ville_naiss like '%-%'").each { |e| e.update(ville_naiss: e.ville_naiss.tr("-", " ")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%É%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/É/, "E")) }

Eleve.where("ville_naiss like '%È%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/È/, "E")) }

Eleve.where("ville_naiss like '%Î%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Î/, "I")) }

Eleve.where("ville_naiss like '%Ç%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Ç/, "C")) }

Eleve.where("ville_naiss like 'PARIS%01%'").each { |e| e.update(ville_naiss: "PARIS 01") }
Eleve.where("ville_naiss like 'PARIS%02%'").each { |e| e.update(ville_naiss: "PARIS 02") }
Eleve.where("ville_naiss like 'PARIS%03%'").each { |e| e.update(ville_naiss: "PARIS 03") }
Eleve.where("ville_naiss like 'PARIS%04%'").each { |e| e.update(ville_naiss: "PARIS 04") }
Eleve.where("ville_naiss like 'PARIS%05%'").each { |e| e.update(ville_naiss: "PARIS 05") }
Eleve.where("ville_naiss like 'PARIS%06%'").each { |e| e.update(ville_naiss: "PARIS 06") }
Eleve.where("ville_naiss like 'PARIS%07%'").each { |e| e.update(ville_naiss: "PARIS 07") }
Eleve.where("ville_naiss like 'PARIS%08%'").each { |e| e.update(ville_naiss: "PARIS 08") }
Eleve.where("ville_naiss like 'PARIS%09%'").each { |e| e.update(ville_naiss: "PARIS 09") }
Eleve.where("ville_naiss like 'PARIS%10%'").each { |e| e.update(ville_naiss: "PARIS 10") }
Eleve.where("ville_naiss like 'PARIS%11%'").each { |e| e.update(ville_naiss: "PARIS 11") }
Eleve.where("ville_naiss like 'PARIS%12%'").each { |e| e.update(ville_naiss: "PARIS 12") }
Eleve.where("ville_naiss like 'PARIS%13%'").each { |e| e.update(ville_naiss: "PARIS 13") }
Eleve.where("ville_naiss like 'PARIS%14%'").each { |e| e.update(ville_naiss: "PARIS 14") }
Eleve.where("ville_naiss like 'PARIS%15%'").each { |e| e.update(ville_naiss: "PARIS 15") }
Eleve.where("ville_naiss like 'PARIS%16%'").each { |e| e.update(ville_naiss: "PARIS 16") }
Eleve.where("ville_naiss like 'PARIS%17%'").each { |e| e.update(ville_naiss: "PARIS 17") }
Eleve.where("ville_naiss like 'PARIS%18%'").each { |e| e.update(ville_naiss: "PARIS 18") }
Eleve.where("ville_naiss like 'PARIS%19%'").each { |e| e.update(ville_naiss: "PARIS 19") }
Eleve.where("ville_naiss like 'PARIS%20%'").each { |e| e.update(ville_naiss: "PARIS 20") }

communes = {}
CSV.foreach("app/services/laposte_hexasmal.csv", col_sep: ";") do |row|
  communes[row[1]] = row[0]
end

Eleve.all.each do |eleve|
  eleve.update(commune_insee_naissance: communes[eleve.ville_naiss])
end
