# frozen_string_literal: true

Fabricator(:etablissement) do
  uai { sequence(:uai) { |i| "000000#{i}X" } }
  nom { sequence(:nom) { |i| "NOM-#{i}" } }
end
