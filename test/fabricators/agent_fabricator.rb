Fabricator(:agent) do
  etablissement
  admin false
  password 'demaulmont'
end

Fabricator(:admin, from: :agent) do
  admin true
end

