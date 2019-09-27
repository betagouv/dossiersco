# frozen_string_literal: true

Fabricator(:dossier_eleve) do
  etablissement
  mef_destination { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
  mef_origine { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
  mef_an_dernier "12345678901"
  division_an_dernier "4 D"
  division "3 A"
  nom { Faker::Name.last_name }
  prenom { Faker::Name.first_name }
  identifiant { sequence(:identifiant) { |i| "IDENTIF#{'I' * (4 - i.to_s.size)}#{i}" } }
  date_naiss "2004-04-27"
  commune_insee_naissance "75112"
  pays_naiss "100"
end

Fabricator(:dossier_eleve_valide, from: :dossier_eleve) do
  etat "validé"
end
