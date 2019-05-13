# frozen_string_literal: true

Fabricator(:resp_legal) do
  dossier_eleve
  priorite 1
  prenom Faker::Name.first_name
  nom Faker::Name.last_name
  tel_personnel  Faker::PhoneNumber.phone_number
  tel_portable   Faker::PhoneNumber.phone_number
  email "henri@laposte.net"
  profession "artisan"
  enfants_a_charge 1
  communique_info_parents_eleves false
  adresse Faker::Address.street_address
  code_postal Faker::Address.zip
  ville Faker::Address.city
  communique_info_parents_eleves true
  lien_de_parente %w[PERE MERE].sample
end
