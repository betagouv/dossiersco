# frozen_string_literal: true

Fabricator(:mef) do
  etablissement
  code { sequence(:code) { |i| "code_mef_#{i}" } }
  libelle { sequence(:libelle) { |i| "lib_mef_#{i}" } }
end
