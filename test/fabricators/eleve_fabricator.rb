# frozen_string_literal: true

Fabricator(:eleve) do
  nom { Faker::Name.last_name }
  prenom { Faker::Name.first_name }
  identifiant { sequence(:identifiant) { |i| "IDENTIF#{'I' * (4 - i.to_s.size)}#{i}" } }
  date_naiss "2004-04-27"
  commune_insee_naissance "75112"
  pays_naiss "100"
end
