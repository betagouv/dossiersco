# frozen_string_literal: true

Fabricator(:mef) do
  etablissement
  code { sequence(:number, 10000000000) }
  libelle { sequence(:libelle) { |i| "lib_mef_#{i}" } }
end
