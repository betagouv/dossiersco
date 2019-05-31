# frozen_string_literal: true

Fabricator(:option_pedagogique) do
  etablissement
  code_matiere Faker::Number.number(10)
  nom Faker::Color.color_name
end
