# frozen_string_literal: true

Fabricator(:piece_attendue) do
  etablissement
end

Fabricator(:piece_attendue_obligatoire, from: :piece_attendue) do
  obligatoire true
end
