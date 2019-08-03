# frozen_string_literal: true


Eleve.all.each {|e| e.update(ville_naiss: e.ville_naiss.upcase)}

Eleve.where("ville_naiss like '%-%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/-/, ' ')) }

Eleve.where("ville_naiss like '%SAINT%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, 'ST')) }

Eleve.where("ville_naiss like '%SAINT%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, 'ST')) }

Eleve.where("ville_naiss like '%É%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/É/, 'E')) }

Eleve.where("ville_naiss like '%È%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/È/, 'E')) }

Eleve.where("ville_naiss like '%Î%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/Î/, 'I')) }

Eleve.where("ville_naiss like '%Ç%'").each {|e| e.update(ville_naiss: e.ville_naiss.gsub(/Ç/, 'C')) }


communes = {}
CSV.foreach("app/services/laposte_hexasmal.csv", col_sep: ";") do |row|
  communes[row[1]] = row[0]
end

Eleve.all.each do |eleve|
  eleve.update(commune_insee_naissance: communes[eleve.ville_naiss])
end

