# frozen_string_literal: true

Fabricator(:etablissement) do
  uai { sequence(:uai) { |i| "UAI-#{i}" } }
end
