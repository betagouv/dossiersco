# frozen_string_literal: true

Fabricator(:contact_urgence) do
  prenom { Faker::Name.first_name }
  nom "bla"
  tel_principal { Faker::PhoneNumber.phone_number }
  tel_secondaire { Faker::PhoneNumber.phone_number }
  dossier_eleve
end
