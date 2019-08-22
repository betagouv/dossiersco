# frozen_string_literal: true

Fabricator(:etablissement) do
  uai { sequence(:number, 1_000_000).to_s + "X" }
  nom { sequence(:nom) { |i| "NOM-#{i}" } }
end

Fabricator(:etablissement_avec_responsables_uploaded, from: :etablissement) do
  responsables_uploaded true
end
