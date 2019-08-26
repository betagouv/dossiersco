# frozen_string_literal: true

Fabricator(:dossier_eleve) do
  eleve
  etablissement
  mef_destination { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
  mef_origine { |attrs| Fabricate(:mef, etablissement: attrs[:etablissement]) }
  mef_an_dernier "12345678901"
  division_an_dernier "4 D"
  division "3 A"
end

Fabricator(:dossier_eleve_valide, from: :dossier_eleve) do
  etat "validé"
end
