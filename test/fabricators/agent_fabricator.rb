Fabricator(:agent) do
  etablissement
  admin false
  identifiant { sequence(:identifiant) { |i| "identifiant#{i}" } }
  password 'demaulmont'
end

Fabricator(:admin, from: :agent) do
  admin true
end

