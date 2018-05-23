require 'roo'
require 'roo-xls'

def import_xls fichier, etablissement_id, nom_a_importer=nil, prenom_a_importer=nil
  colonnes = {sexe: 0, nationalite: 1, prenom: 6, prenom_2: 7, prenom_3: 8, nom: 4, date_naiss: 9, identifiant: 11,
              ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, niveau_classe_ant: 33, classe_ant: 36,
              nom_resp_legal1: 99, prenom_resp_legal1: 101,
              tel_principal_resp_legal1: 102, tel_secondaire_resp_legal1: 104, lien_parente_resp_legal1: 103,
              adresse_resp_legal1: 108, ville_resp_legal1: 112, code_postal_resp_legal1: 113, email_resp_legal1: 106,
              nom_resp_legal2: 118, prenom_resp_legal2: 120, tel_principal_resp_legal2: 121,
              tel_secondaire_resp_legal2: 123, lien_parente_resp_legal2: 122, adresse_resp_legal2: 127,
              ville_resp_legal2: 131, code_postal_resp_legal2: 132, email_resp_legal2: 125}

  xls_document = Roo::Spreadsheet.open fichier
  lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

  portables = 0
  emails = 0
  nb_eleves_importes = 0
  lignes_siecle.each do |row|
    ligne_siecle = xls_document.row(row)

    resultat = import_ligne etablissement_id, ligne_siecle, colonnes, nom_a_importer, prenom_a_importer

    portables += 1 if resultat[:portable]
    emails += 1 if resultat[:email]
    nb_eleves_importes += 1 if resultat[:eleve_importe]
  end
  {portable: (portables * 100) / nb_eleves_importes, email: (emails * 100) / nb_eleves_importes,
   eleves: nb_eleves_importes}
end

def import_ligne etablissement_id, ligne_siecle, colonnes, nom_a_importer, prenom_a_importer
  resultat = {portable: false, email: false, eleve_importe: false}

  champs_eleve = [:sexe,:nationalite, :date_naiss, :prenom, :prenom_2, :prenom_3, :nom, :identifiant, :pays_naiss,
    :commune_naiss, :ville_naiss_etrangere, :classe_ant, :niveau_classe_ant]

  donnees_eleve = {}
  champs_eleve.each do |champ|
    donnees_eleve[champ] = ligne_siecle[colonnes[champ]]
  end

  donnees_eleve = traiter_donnees_eleve donnees_eleve

  return resultat if donnees_eleve[:niveau_classe_ant].nil?
  return resultat if (nom_a_importer != nil and nom_a_importer != '') and donnees_eleve[:nom] != nom_a_importer
  return resultat if (prenom_a_importer != nil and prenom_a_importer != '') and donnees_eleve[:prenom] != prenom_a_importer

  eleve = Eleve.find_or_initialize_by(identifiant: donnees_eleve[:identifiant])
  eleve.update_attributes!(donnees_eleve)

  dossier_eleve = DossierEleve.find_or_initialize_by(eleve_id: eleve.id)
  dossier_eleve.update_attributes!(
      eleve_id: eleve.id,
      etablissement_id: etablissement_id
  )

  champs_resp_legal = {}
  portable = false
  email = false
  ['1', '2'].each do |i|
    ['nom_resp_legal',
     'prenom_resp_legal',
     'tel_principal_resp_legal',
     'tel_secondaire_resp_legal',
     'lien_parente_resp_legal',
     'adresse_resp_legal',
     'code_postal_resp_legal',
     'ville_resp_legal',
     'email_resp_legal'
    ].each { |j| champs_resp_legal[j] = ligne_siecle[colonnes["#{j}#{i}".to_sym]] }

    resp_legal = RespLegal.find_or_initialize_by(dossier_eleve_id: dossier_eleve.id, priorite: i.to_i)
    resp_legal.update_attributes!(
        dossier_eleve_id: dossier_eleve.id,
        nom: champs_resp_legal['nom_resp_legal'],
        prenom: champs_resp_legal['prenom_resp_legal'],
        tel_principal: champs_resp_legal['tel_principal_resp_legal'],
        tel_secondaire: champs_resp_legal['tel_secondaire_resp_legal'],
        lien_de_parente: champs_resp_legal['lien_parente_resp_legal'],
        ville: champs_resp_legal['ville_resp_legal'],
        email: champs_resp_legal['email_resp_legal'],
        adresse: champs_resp_legal['adresse_resp_legal'],
        code_postal: champs_resp_legal['code_postal_resp_legal'],
        priorite: i.to_i)
    resultat[:portable] = true if resp_legal.tel_principal =~ /^0[67]/ or resp_legal.tel_secondaire =~ /^0[67]/
    resultat[:email] = true if resp_legal.email =~ /@.*\./
    resultat[:eleve_importe] = true
  end
  return resultat
end

def traiter_donnees_eleve donnees_eleve
  if donnees_eleve[:sexe] == 'M'
    donnees_eleve[:sexe] = 'Masculin'
  elsif donnees_eleve[:sexe] == 'F'
    donnees_eleve[:sexe] = 'Féminin'
  end
  if donnees_eleve[:date_naiss].class == Date
    donnees_eleve[:date_naiss] = donnees_eleve[:date_naiss].strftime('%Y-%m-%d')
  else
    donnees_eleve[:date_naiss] = donnees_eleve[:date_naiss].split('/').reverse.join('-')
  end
  if donnees_eleve[:pays_naiss] == 'FRANCE'
    donnees_eleve[:ville_naiss] = donnees_eleve[:commune_naiss]
  else
    donnees_eleve[:ville_naiss] = donnees_eleve[:ville_naiss_etrangere]
  end
  donnees_eleve[:nationalite] = donnees_eleve[:pays_naiss]

  donnees_eleve.delete(:commune_naiss)
  donnees_eleve.delete(:ville_naiss_etrangere)

  return donnees_eleve
end