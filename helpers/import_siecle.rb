require 'roo'
require 'roo-xls'

def import_xls fichier, etablissement_id, nom_a_importer=nil, prenom_a_importer=nil
  colonnes = {sexe: 0, pays_nat: 1, prenom: 6, prenom_2: 7, prenom_3: 8, nom: 4, date_naiss: 9, identifiant: 11,
              ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, niveau_classe_ant: 33, classe: 36,
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
    sexe = xls_document.row(row)[colonnes[:sexe]]
    if sexe == 'M'
      sexe = 'Masculin'
    elsif sexe == 'F'
      sexe = 'Féminin'
    end
    pays_nat = xls_document.row(row)[colonnes[:pays_nat]]
    date = xls_document.row(row)[colonnes[:date_naiss]]
    if date.class == Date
      date_naiss = date.strftime('%Y-%m-%d')
    else
      date_naiss = date.split('/').reverse.join('-')
    end
    prenom = xls_document.row(row)[colonnes[:prenom]]
    prenom_2 = xls_document.row(row)[colonnes[:prenom_2]]
    prenom_3 = xls_document.row(row)[colonnes[:prenom_3]]
    nom = xls_document.row(row)[colonnes[:nom]]
    identifiant = xls_document.row(row)[colonnes[:identifiant]]
    pays_naiss = xls_document.row(row)[colonnes[:pays_naiss]]
    if pays_naiss == 'FRANCE'
      ville_naiss = xls_document.row(row)[colonnes[:commune_naiss]]
    else
      ville_naiss = xls_document.row(row)[colonnes[:ville_naiss_etrangere]]
    end
    class_ant = xls_document.row(row)[colonnes[:classe]]
    niveau_classe_ant = xls_document.row(row)[colonnes[:niveau_classe_ant]]

    next if niveau_classe_ant.nil?
    next if (nom_a_importer != nil and nom_a_importer != '') and nom != nom_a_importer
    next if (prenom_a_importer != nil and prenom_a_importer != '') and prenom != prenom_a_importer

    eleve = Eleve.find_or_initialize_by(identifiant: identifiant)
    eleve.update_attributes!(
        identifiant: identifiant,
        sexe: sexe,
        nationalite: pays_nat,
        date_naiss: date_naiss,
        prenom: prenom,
        prenom_2: prenom_2,
        prenom_3: prenom_3,
        nom: nom,
        pays_naiss: pays_naiss,
        ville_naiss: ville_naiss,
        classe_ant: class_ant,
        niveau_classe_ant: niveau_classe_ant
    )

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
      ].each { |j| champs_resp_legal[j] = xls_document.row(row)[colonnes["#{j}#{i}".to_sym]] }

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
      portable = true if resp_legal.tel_principal =~ /^0[67]/ or resp_legal.tel_secondaire =~ /^0[67]/
      email = true if resp_legal.email =~ /@.*\./
    end
    portables += 1 if portable
    emails += 1 if email
    nb_eleves_importes += 1
  end
  {portable: (portables * 100) / nb_eleves_importes, email: (emails * 100) / nb_eleves_importes,
   eleves: nb_eleves_importes}
end