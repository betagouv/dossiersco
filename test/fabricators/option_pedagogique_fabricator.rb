# frozen_string_literal: true

Fabricator(:option_pedagogique) do
  etablissement
  code_gestion Faker::Number.number(10)
  code_matiere Faker::Number.number(6)
  nom Faker::Color.color_name
end
