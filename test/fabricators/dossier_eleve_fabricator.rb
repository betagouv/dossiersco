# frozen_string_literal: true

Fabricator(:dossier_eleve) do
  eleve
  etablissement
  mef_destination { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
  mef_origine { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
end
