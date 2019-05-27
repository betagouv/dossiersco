# frozen_string_literal: true

Fabricator(:contact_urgence) do
  dossier_eleve
  nom Faker::Name.last_name
  tel_principal Faker::PhoneNumber.phone_number
  tel_secondaire Faker::PhoneNumber.phone_number
end
