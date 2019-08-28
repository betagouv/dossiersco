# frozen_string_literal: true

Eleve.where("ville_naiss is not null").each { |e| e.update(ville_naiss: e.ville_naiss.upcase) }

Eleve.where("ville_naiss like '%-%'").each { |e| e.update(ville_naiss: e.ville_naiss.tr("-", " ")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%SAINT%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/SAINT/, "ST")) }

Eleve.where("ville_naiss like '%É%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/É/, "E")) }

Eleve.where("ville_naiss like '%È%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/È/, "E")) }

Eleve.where("ville_naiss like '%Î%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Î/, "I")) }

Eleve.where("ville_naiss like '%Ç%'").each { |e| e.update(ville_naiss: e.ville_naiss.gsub(/Ç/, "C")) }

Eleve.where(ville_naiss: "PARIS").update_all(ville_naiss: "PARIS 01")
Eleve.where(ville_naiss: "PARIS 17E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 17")
Eleve.where(ville_naiss: "PARIS 14E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 14")
Eleve.where(ville_naiss: "PARIS 18E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 18")
Eleve.where(ville_naiss: "PARIS 11E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 11")
Eleve.where(ville_naiss: "PARIS 12E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 12")
Eleve.where(ville_naiss: "PARIS 15E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 15")
Eleve.where(ville_naiss: "PARIS 19E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 19")
Eleve.where(ville_naiss: "PARIS 16E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 16")
Eleve.where(ville_naiss: "PARIS 20E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 20")
Eleve.where(ville_naiss: "PARIS 13E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 13")
Eleve.where(ville_naiss: "PARIS 10E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 10")
Eleve.where(ville_naiss: "PARIS  16E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 16")
Eleve.where(ville_naiss: "PARIS  7E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 07")
Eleve.where(ville_naiss: "PARIS  14E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 14")
Eleve.where(ville_naiss: "PARIS  4E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 04")
Eleve.where(ville_naiss: "PARIS  13ER ARRONDISSEMENT").update_all(ville_naiss: "PARIS 13")
Eleve.where(ville_naiss: "PARIS  18E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 18")
Eleve.where(ville_naiss: "PARIS  12E ARRONDISSEMENT").update_all(ville_naiss: "PARIS 12")
Eleve.where(ville_naiss: "PARIS 20 ARRONDISSEMENT").update_all(ville_naiss: "PARIS 20")
Eleve.where(ville_naiss: "PARIS ").update_all(ville_naiss: "PARIS 01")
Eleve.where(ville_naiss: "PARIS  2E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 02")
Eleve.where(ville_naiss: "PARIS 12 EME  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 12")
Eleve.where(ville_naiss: "PARIS  5E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 05")
Eleve.where(ville_naiss: "PARIS  9E  ARRONDISSEMENT").update_all(ville_naiss: "PARIS 09")
Eleve.where(ville_naiss: "PARIS 75014").update_all(ville_naiss: "PARIS 14")

Eleve.where(ville_naiss: "LYON  1ER ARRONDISSEMENT").update_all(ville_naiss: "LYON 01")
Eleve.where(ville_naiss: "LYON  2E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 02")
Eleve.where(ville_naiss: "LYON  3E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 03")
Eleve.where(ville_naiss: "LYON  4E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 04")
Eleve.where(ville_naiss: "LYON  6E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 06")
Eleve.where(ville_naiss: "LYON  7E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 07")
Eleve.where(ville_naiss: "LYON  8E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 08")
Eleve.where(ville_naiss: "LYON  9E  ARRONDISSEMENT").update_all(ville_naiss: "LYON 09")

Eleve.where(ville_naiss: "MARSEILLE  5E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 05")
Eleve.where(ville_naiss: "MARSEILLE 12E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 12")
Eleve.where(ville_naiss: "MARSEILLE 15E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 15")
Eleve.where(ville_naiss: "MARSEILLE  6E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 06")
Eleve.where(ville_naiss: "MARSEILLE  7E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 07")
Eleve.where(ville_naiss: "MARSEILLE 8E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 08")
Eleve.where(ville_naiss: "MARSEILLE 13E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 13")
Eleve.where(ville_naiss: "MARSEILLE 11E  ARRONDISSEMENT").update_all(ville_naiss: "MARSEILLE 11")

communes = {}
CSV.foreach("app/services/laposte_hexasmal.csv", col_sep: ";") do |row|
  communes[row[1]] = row[0]
end

Eleve.all.each do |eleve|
  eleve.update(commune_insee_naissance: communes[eleve.ville_naiss])
end
