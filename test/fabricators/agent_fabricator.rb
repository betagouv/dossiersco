Fabricator(:agent) do
  etablissement
  admin false
  password BCrypt::Password.create("truc")
end

Fabricator(:admin, from: :agent) do
  admin true
end

