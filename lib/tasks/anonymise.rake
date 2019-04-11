require 'faker'

namespace :db do

  desc "Anonymise les données élèves et resp_légal"
  task :anonymise => :environment do
    Eleve.all.each do |eleve|
      eleve.identifiant = Faker::Alphanumeric.alpha(10).upcase
      eleve.nom = Faker::Name.last_name if eleve.nom.present?
      eleve.prenom = Faker::Name.first_name if eleve.prenom.present?
      eleve.ville_naiss = Faker::Address.city if eleve.ville_naiss.present?
      eleve.save!
    end

    RespLegal.all.each do |resp|
      resp.nom = Faker::Name.last_name if resp.nom.present?
      resp.prenom = Faker::Name.first_name if resp.prenom.present?
      resp.adresse = Faker::Address.street_address if resp.adresse.present?
      resp.code_postal = Faker::Address.zip if resp.code_postal.present?
      resp.ville = Faker::Address.city if resp.ville.present?
      resp.tel_principal = Faker::PhoneNumber.phone_number if resp.tel_principal.present?
      resp.tel_secondaire = Faker::PhoneNumber.phone_number if resp.tel_secondaire.present?
      resp.save!
    end

    ContactUrgence.all.each do |urgence|
      urgence.nom = Faker::Name.last_name if urgence.nom.present?
      urgence.prenom = Faker::Name.first_name if urgence.prenom.present?
      urgence.tel_principal = Faker::PhoneNumber.phone_number if urgence.tel_principal.present?
      urgence.tel_secondaire = Faker::PhoneNumber.phone_number if urgence.tel_secondaire.present?
      urgence.save!
    end
  end

end

