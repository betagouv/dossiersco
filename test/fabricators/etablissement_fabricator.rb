Fabricator(:etablissement) do
  uai { sequence(:uai) {|i| "UAI-#{i}" } }
end
