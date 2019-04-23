# frozen_string_literal: true

Fabricator(:resp_legal) do
  dossier_eleve
  priorite 1
  prenom { sequence(:prenom) { |i| "Henri_#{i}" } }
  nom { sequence(:nom) { |i| "Ford_#{i}" } }
  tel_personnel  { sequence(:tel) { |i| "012345670#{i}" } }
  tel_portable   { sequence(:tel) { |i| "022345670#{i}" } }
  email 'henri@laposte.net'
  profession '11'
  enfants_a_charge 1
  communique_info_parents_eleves false
end
