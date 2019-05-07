# frozen_string_literal: true

Fabricator(:regime_sortie) do
  etablissement
  nom { sequence(:nom) { |i| "nom_#{i}" } }
end
