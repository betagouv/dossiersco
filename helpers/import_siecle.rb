require 'roo'
require 'roo-xls'

def import_xls fichier, etablissement_id
  # chargement du fichier excel affelnet
  xls_document = Roo::Spreadsheet.open fichier

  (xls_document.first_row+1..xls_document.last_row).each do |row|
    colonnes = {sexe: 0, pays_nat: 1, prenom: 6, nom: 4, date_naiss: 9, identifiant: 11,
                ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, classe: 36,
                nom_resp_legal1: 99, prenom_resp_legal1: 101,
                tel_principal_resp_legal1: 102, tel_secondaire_resp_legal1: 104, lien_parente_resp_legal1: 103,
                adresse_resp_legal1: 108, ville_resp_legal1: 112, code_postal_resp_legal1: 113, email_resp_legal1: 106,
                nom_resp_legal2: 118, prenom_resp_legal2: 120, tel_principal_resp_legal2: 121,
                tel_secondaire_resp_legal2: 123, lien_parente_resp_legal2: 122, adresse_resp_legal2: 127,
                ville_resp_legal2: 131, code_postal_resp_legal2: 132, email_resp_legal2: 125}

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
    nom = xls_document.row(row)[colonnes[:nom]]
    identifiant = xls_document.row(row)[colonnes[:identifiant]]
    pays_naiss = xls_document.row(row)[colonnes[:pays_naiss]]
    if pays_naiss == 'FRANCE'
      ville_naiss = xls_document.row(row)[colonnes[:commune_naiss]]
    else
      ville_naiss = xls_document.row(row)[colonnes[:ville_naiss_etrangere]]
    end
    classe_ant = xls_document.row(row)[colonnes[:classe]]

    eleve = Eleve.find_or_initialize_by(identifiant: identifiant)
    eleve.update_attributes!(
        identifiant: identifiant,
        sexe: sexe,
        nationalite: pays_nat,
        date_naiss: date_naiss,
        prenom: prenom,
        nom: nom,
        pays_naiss: pays_naiss,
        ville_naiss: ville_naiss,
        classe_ant: classe_ant
    )

    dossier_eleve = DossierEleve.find_or_initialize_by(eleve_id: eleve.id)
    dossier_eleve.update_attributes!(
        eleve_id: eleve.id,
        etablissement_id: etablissement_id
    )

    champs_resp_legal = {}
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
    end
  end
end