# frozen_string_literal: true

Fabricator(:agent) do
  etablissement
  admin false
  email { sequence(:email) { |i| "toto_#{i}@test.com" } }
  password 'demaulmont'
end

Fabricator(:admin, from: :agent) do
  admin true
end
