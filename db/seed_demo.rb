# frozen_string_literal: true

puts "loading Etablissement"
etablissement = Etablissement.create("nom" => "Établissement de démo", "ville" => "Paris", "uai" => "0123456S")

puts "loading Agent"
admin = Agent.create("prenom" => "Principale", "nom" => "Papillon", "etablissement" => etablissement, "admin" => true, "password_digest" => "$2a$10$7F2E3eyr4Z2j0JdhFI3o6et1wVwhxPAJAET1V1AMcdfy36jeWIB7y", "email" => "ce.0753936w@ac-paris.fr")
superAdmin = Agent.create("prenom" => "Pierre", "nom" => "De Maulmont", "etablissement" => etablissement, "admin" => true, "password_digest" => "$2a$10$.aMYRnJeqdQn/4pI61y81edPVMV0UvevcMGdk7VgCwu9YfFgVXnnG", "email" => "pierre.de-maulmont@ac-paris.fr")

puts "loading OptionPedagogique"
anglais_lv1 = OptionPedagogique.create("nom" => "ANGLAIS LV1", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "AGL1")
espagnol_lv2_nd = OptionPedagogique.create("nom" => "ESPAGNOL LV2 ND", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "ESP2ND")
espagnol_lv2 = OptionPedagogique.create("nom" => "ESPAGNOL LV2", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "EPS2")
allemand_lv2_nd = OptionPedagogique.create("nom" => "ALLEMAND LV2 ND", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "ALL2ND")
allemand_lv2 = OptionPedagogique.create("nom" => "ALLEMAND LV2", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "ALL2")
latin = OptionPedagogique.create("nom" => "LCA LATIN", "etablissement" => etablissement, "code_matiere" => "LAT")
italien_lv2 = OptionPedagogique.create("nom" => "ITALIEN LV2", "obligatoire" => true, "etablissement" => etablissement, "code_matiere" => "ITA2")

puts "loading Mef"
Mef.create("libelle" => "3EME", "code" => "10310019110", "etablissement" => etablissement,  "options_pedagogiques" => [anglais_lv1, espagnol_lv2_nd, espagnol_lv2, allemand_lv2_nd, latin, allemand_lv2, italien_lv2])
Mef.create("libelle" => "3EME SEGPA RENOV. : VENTE DISTRIB.MAGAS", "code" => "1671000C11A", "etablissement" => etablissement)
Mef.create("libelle" => "3EME SEGPA RENOV. : HYGIENE ALIMENT.SERV", "code" => "1671000D11A", "etablissement" => etablissement)
Mef.create("libelle" => "4EME SEGPA", "code" => "16610002110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1])
Mef.create("libelle" => "4EME", "code" => "10210001110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1, espagnol_lv2_nd, espagnol_lv2, allemand_lv2_nd, latin, allemand_lv2, italien_lv2])
Mef.create("libelle" => "4EME HORAIRES AMENAGES MUSIQUE", "code" => "1021000C11A", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1, espagnol_lv2, latin, allemand_lv2])
Mef.create("libelle" => "5EME", "code" => "10110001110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1, espagnol_lv2, latin, allemand_lv2])
Mef.create("libelle" => "5EME HORAIRES AMENAGES MUSIQUE", "code" => "1011000C11A", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1, espagnol_lv2, allemand_lv2])
Mef.create("libelle" => "5EME SEGPA", "code" => "16510002110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1])
Mef.create("libelle" => "6EME", "code" => "10010012110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1])
Mef.create("libelle" => "6EME SEGPA", "code" => "16410002110", "etablissement" => etablissement, "options_pedagogiques" => [anglais_lv1])

puts "création d'élèves et de dossier associés"

300.times do

  niveau = Faker::Educator.niveau

  mef_origine = Mef.find_by(libelle: niveau[0])
  mef_destination = Mef.niveau_superieur(mef_origine)

  eleve = Eleve.create!(
    "identifiant" => Faker::Alphanumeric.alpha(10).upcase,
    "prenom" => Faker::Name.first_name,
    "nom" => Faker::Name.last_name,
    "sexe" => Faker::Boolean.boolean ? "Masculin" : "Féminin",
    "ville_naiss" => Faker::Address.city,
    "nationalite" => "100",
    "classe_ant" => niveau[1],
    "date_naiss" => Faker::Date.birthday(11, 17),
    "pays_naiss" => "100",
    "niveau_classe_ant" => niveau[0]
  )

  dossier_eleve = DossierEleve.create!(
    "eleve" => eleve,
    "etablissement" => etablissement,
    "etat" => "pas connecté",
    "satisfaction" => 0,
    "autorise_photo_de_classe" => true,
    "etape_la_plus_avancee" => "accueil",
    "mef_origine" => mef_origine,
    "mef_destination" => mef_destination
  )

  taille_min = 2 % mef_origine.options_pedagogiques.length
  taille_max = mef_origine.options_pedagogiques.length - 1
  taille_du_sample = rand(taille_min..taille_max)

  options_origines = {}
  mef_origine.options_pedagogiques.sample(taille_du_sample).each do |option_origine|
    options_origines[option_origine.id] = {
      code_matiere: option_origine.code_matiere,
      nom: option_origine.nom
    }
    dossier_eleve.options_pedagogiques << option_origine
  end

  dossier_eleve.update!(options_origines: options_origines)


  parente = %w[MERE PERE]
  parente_index = Faker::Boolean.boolean ? 0 : 1

  RespLegal.create!(
    "dossier_eleve" => dossier_eleve,
    "lien_de_parente" => parente[parente_index],
    "priorite" => 1,
    "prenom" => Faker::Name.first_name,
    "nom" => Faker::Name.last_name,
    "adresse" => "98 Passage de Caumartin",
    "code_postal" => "75012",
    "ville" => "Test",
    "tel_personnel" => "03 45 83 62 91",
    "tel_portable" => "02 70 51 44 33",
    "adresse_ant" => "15 rue des jardiniers",
    "ville_ant" => "Test",
    "code_postal_ant" => "75012",
    "pays" => "100",
    "enfants_a_charge" => 1,
    "profession" => "professeur, profession scientifique",
    "communique_info_parents_eleves" => false
  )

  next unless Faker::Boolean.boolean

  RespLegal.create!(
    "dossier_eleve" => dossier_eleve,
    "lien_de_parente" => parente[(parente_index + 1) % 1],
    "priorite" => 2,
    "prenom" => Faker::Name.first_name,
    "nom" => Faker::Name.last_name,
    "adresse" => "98 Passage de Caumartin",
    "code_postal" => "75012",
    "ville" => "Test",
    "tel_personnel" => "03 45 83 62 91",
    "tel_portable" => "02 70 51 44 33",
    "adresse_ant" => "15 rue des jardiniers",
    "ville_ant" => "Test",
    "code_postal_ant" => "75012",
    "pays" => "100",
    "profession" => "professeur, profession scientifique",
    "communique_info_parents_eleves" => false
  )
end
