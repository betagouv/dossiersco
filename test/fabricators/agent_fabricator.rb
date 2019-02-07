Fabricator(:agent) do
  etablissement
  admin false
  email { sequence(:email) { |i| "toto_#{i}@test.com"} }
  identifiant { sequence(:identifiant) { |i| "identifiant#{i}" } }
  password 'demaulmont'
end

Fabricator(:admin, from: :agent) do
  admin true
end

