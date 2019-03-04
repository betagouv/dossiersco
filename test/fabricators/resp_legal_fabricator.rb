# frozen_string_literal: true

Fabricator(:resp_legal) do
  dossier_eleve
  priorite 1
  prenom { sequence(:prenom) { |i| "Henri_#{i}" } }
  nom { sequence(:nom) { |i| "Ford_#{i}" } }
  tel_principal  { sequence(:tel) { |i| "012345670#{i}" } }
  tel_secondaire   { sequence(:tel) { |i| "022345670#{i}" } }
end
