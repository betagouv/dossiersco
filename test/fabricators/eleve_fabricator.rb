# frozen_string_literal: true

Fabricator(:eleve) do
  nom { sequence(:nom) { |i| "nom#{i}" } }
  prenom { sequence(:prenom) { |i| "prenom#{i}" } }
  identifiant { sequence(:identifiant) { |i| "IDENTIFIANT#{i}" } }
  date_naiss "2004-04-27"
end
