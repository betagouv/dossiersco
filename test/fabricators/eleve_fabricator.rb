# frozen_string_literal: true

Fabricator(:eleve) do
  identifiant { sequence(:identifiant) { |i| "IDENTIFIANT#{i}" } }
  date_naiss '2004-04-27'
end
