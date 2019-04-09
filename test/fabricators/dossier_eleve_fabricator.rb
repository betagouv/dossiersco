# frozen_string_literal: true

Fabricator(:dossier_eleve) do
  eleve
  etablissement
  mef_destination { Fabricate(:mef) }
  mef_origine { Fabricate(:mef) }
end
