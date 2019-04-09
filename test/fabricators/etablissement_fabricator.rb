# frozen_string_literal: true

Fabricator(:etablissement) do
  uai { sequence(:number, 1000000).to_s + "X" }
  nom { sequence(:nom) { |i| "NOM-#{i}" } }
end
