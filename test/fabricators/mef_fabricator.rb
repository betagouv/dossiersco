# frozen_string_literal: true

Fabricator(:mef) do
  etablissement
  code { sequence(:number, 10_000_000_000) }
  libelle { sequence(:libelle) { |i| "lib_mef_#{i}" } }
end
