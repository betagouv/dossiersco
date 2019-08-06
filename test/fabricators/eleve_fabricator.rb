# frozen_string_literal: true

Fabricator(:eleve) do
  nom { sequence(:nom) { |i| "nom#{i}" } }
  prenom { sequence(:prenom) { |i| "prenom#{i}" } }
  identifiant { sequence(:identifiant) { |i| "IDENTIF#{'I' * (4 - i.to_s.size)}#{i}" } }
  date_naiss "2004-04-27"
  commune_insee_naissance "75112"
end
