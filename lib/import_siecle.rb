require 'roo'
require 'roo-xls'
COLONNES = {sexe: 0, nationalite: 1, prenom: 6, prenom_2: 7, prenom_3: 8, nom: 4, date_naiss: 9, identifiant: 11,
            ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22, code_mef: 32, niveau_classe_ant: 33, classe_ant: 34,
            nom_resp_legal1: 99, prenom_resp_legal1: 101, date_sortie: 13,
            tel_principal_resp_legal1: 102, tel_secondaire_resp_legal1: 104, lien_de_parente_resp_legal1: 103,
            adresse_resp_legal1: 108, ville_resp_legal1: 112, code_postal_resp_legal1: 113, email_resp_legal1: 106,
            nom_resp_legal2: 118, prenom_resp_legal2: 120, tel_principal_resp_legal2: 121,
            tel_secondaire_resp_legal2: 123, lien_de_parente_resp_legal2: 122, adresse_resp_legal2: 127,
            ville_resp_legal2: 131, code_postal_resp_legal2: 132, email_resp_legal2: 125}

def import_xls fichier, etablissement_id, nom_a_importer=nil, prenom_a_importer=nil

  import_mef(fichier, etablissement_id)
  import_options_pedagogiques(fichier, etablissement_id)
  compte_rendu = import_dossiers_eleve(fichier, etablissement_id, nom_a_importer, prenom_a_importer)
  compte_rendu
end

def import_dossiers_eleve(fichier, etablissement_id, nom_a_importer, prenom_a_importer)
  xls_document = Roo::Spreadsheet.open fichier
  lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

  portables = 0
  emails = 0
  nb_eleves_importes = 0

  lignes_siecle.each do |row|
    ligne_siecle = xls_document.row(row)

    resultat = import_ligne etablissement_id, ligne_siecle, nom_a_importer, prenom_a_importer

    portables += 1 if resultat[:portable]
    emails += 1 if resultat[:email]
    nb_eleves_importes += 1 if resultat[:eleve_importe]
  end

  {portable: (portables * 100) / nb_eleves_importes, email: (emails * 100) / nb_eleves_importes,
   eleves: nb_eleves_importes}
end

def import_mef(fichier, etablissement_id)
  xls_document = Roo::Spreadsheet.open fichier
  lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

  lignes_siecle.each do |row|
    ligne_siecle = xls_document.row(row)

    next unless ligne_siecle[COLONNES[:code_mef]].present?
    next unless ligne_siecle[COLONNES[:niveau_classe_ant]].present?

    Mef.find_or_create_by!(etablissement_id: etablissement_id, code: ligne_siecle[COLONNES[:code_mef]], libelle: ligne_siecle[COLONNES[:niveau_classe_ant]])
  end
end

def import_options_pedagogiques(fichier, etablissement_id)
  xls_document = Roo::Spreadsheet.open fichier
  lignes_siecle = (xls_document.first_row + 1..xls_document.last_row)

  lignes_siecle.each do |row|
    ligne_siecle = xls_document.row(row)
    [38,42,46,50,54,58,62,66,70,74].each do |colonne|
      next unless ligne_siecle[colonne].present?
      option = OptionPedagogique.find_or_create_by(etablissement_id: etablissement_id, nom: ligne_siecle[colonne])
      option.update(obligatoire: true) if ligne_siecle[colonne + 1] == 'O'
      if ligne_siecle[COLONNES[:code_mef]].present?
        mef = Mef.find_by(code: ligne_siecle[COLONNES[:code_mef]], etablissement_id: etablissement_id)
        option.mef << mef
      end
    end
  end
end

def import_ligne_adresse etablissement_id, ligne_siecle
  eleve = Eleve.find_by(identifiant: ligne_siecle[COLONNES[:identifiant]])
  return unless eleve.present?

  champs_resp_legal = [:code_postal, :ville]

  ['1', '2'].each do |i|
    donnees_resp_legal = {}
    champs_resp_legal.each do |champ|
      donnees_resp_legal[champ] = ligne_siecle[COLONNES["#{champ}_resp_legal#{i}".to_sym]]
    end

    resp_legal = RespLegal.find_by(priorite: i.to_i, dossier_eleve_id: eleve.dossier_eleve.id)
    resp_legal.update(
        ville_ant: donnees_resp_legal[:ville],
        adresse_ant: (concatener_adresse ligne_siecle, resp_legal.priorite),
        code_postal_ant: donnees_resp_legal[:code_postal])
  end
end

def concatener_adresse ligne_siecle, priorite
  colonnes_adresse = { 'resp_legal1' => [108, 109, 110, 111], 'resp_legal2' => [127, 128, 129, 130]}
  adresse = ""
  colonnes_adresse["resp_legal#{priorite}"].each do |colonne|
    adresse << "#{ligne_siecle[colonne]} \n " unless ligne_siecle[colonne].nil?
  end
  adresse
end


def import_ligne etablissement_id, ligne_siecle, nom_a_importer=nil, prenom_a_importer=nil

  resultat = {portable: false, email: false, eleve_importe: false}

  champs_eleve = [:sexe,:nationalite, :date_naiss, :prenom, :prenom_2, :prenom_3, :nom,
    :identifiant, :pays_naiss, :commune_naiss, :ville_naiss_etrangere, :classe_ant,
    :niveau_classe_ant]

  donnees_eleve = {}
  champs_eleve.each do |champ|
    donnees_eleve[champ] = ligne_siecle[COLONNES[champ]]
  end

  donnees_eleve = traiter_donnees_eleve donnees_eleve

  return resultat if donnees_eleve[:niveau_classe_ant].nil? || !ligne_siecle[COLONNES[:date_sortie]].nil?
  return resultat if (nom_a_importer != nil and nom_a_importer != '') and donnees_eleve[:nom] != nom_a_importer
  return resultat if (prenom_a_importer != nil and prenom_a_importer != '') and donnees_eleve[:prenom] != prenom_a_importer

  eleve = Eleve.find_or_initialize_by(identifiant: donnees_eleve[:identifiant])

  return resultat if eleve.id.present? && donnees_eleve[:classe_ant] != eleve.classe_ant

  eleve.update_attributes!(donnees_eleve)

  import_options etablissement_id, ligne_siecle, eleve

  mef_origine = Mef.find_by(code: ligne_siecle[COLONNES[:code_mef]], libelle: ligne_siecle[COLONNES[:niveau_classe_ant]])
  mef_destination = Mef.niveau_supérieur(mef_origine) if mef_origine.present?

  dossier_eleve = DossierEleve.find_or_initialize_by(eleve_id: eleve.id)
  dossier_eleve.update_attributes!(
      eleve_id: eleve.id,
      etablissement_id: etablissement_id,
      mef_origine: mef_origine,
      mef_destination: mef_destination
  )

  champs_resp_legal = [:nom, :prenom, :tel_principal, :tel_secondaire, :lien_de_parente,
    :adresse, :code_postal, :ville, :email]

  donnees_resp_legal = {}
  ['1', '2'].each do |i|
    champs_resp_legal.each do |champ|
      donnees_resp_legal[champ] = ligne_siecle[COLONNES["#{champ}_resp_legal#{i}".to_sym]]
    end

    donnees_resp_legal[:dossier_eleve_id] = dossier_eleve.id
    donnees_resp_legal[:priorite] = i.to_i

    donnees_resp_legal[:adresse_ant] = donnees_resp_legal[:adresse]
    donnees_resp_legal[:ville_ant] = donnees_resp_legal[:ville]
    donnees_resp_legal[:code_postal_ant] = donnees_resp_legal[:code_postal]

    resp_legal = RespLegal.find_or_initialize_by(dossier_eleve_id: dossier_eleve.id, priorite: i.to_i)
    resp_legal.update_attributes!(donnees_resp_legal)

    resultat[:portable] = true if resp_legal.tel_principal =~ /^0[67]/ or resp_legal.tel_secondaire =~ /^0[67]/
    resultat[:email] = true if resp_legal.email =~ /@.*\./
  end

  resultat[:eleve_importe] = true

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

def import_options etablissement_id, ligne_siecle, eleve
  colonnes_options = [
    {cle_gestion: 37, libelle: 38, code_modalite: 39},
    {cle_gestion: 41, libelle: 42, code_modalite: 43},
    {cle_gestion: 45, libelle: 46, code_modalite: 47},
    {cle_gestion: 49, libelle: 50, code_modalite: 51},
    {cle_gestion: 53, libelle: 54, code_modalite: 55},
    {cle_gestion: 57, libelle: 58, code_modalite: 59},
    {cle_gestion: 61, libelle: 62, code_modalite: 63},
    {cle_gestion: 65, libelle: 66, code_modalite: 67},
    {cle_gestion: 69, libelle: 70, code_modalite: 71},
    {cle_gestion: 73, libelle: 74, code_modalite: 75}
  ]
  colonnes_options.each do |colonne|
    libelle = ligne_siecle[colonne[:libelle]]

    unless libelle.nil?
      cle_gestion = ligne_siecle[colonne[:cle_gestion]]
      code_modalite = ligne_siecle[colonne[:code_modalite]]

      option = creer_option libelle, cle_gestion, code_modalite
      eleve.option << option
    end
  end
end

def creer_option libelle, cle_gestion, code_modalite
  cle_groupes = {AGL1: "Langue vivante 1", ESP2: "Langue vivante 2", ES2ND: "Langue vivante 2",
    ALL2: "Langue vivante 2", AL2ND: "Langue vivante 2", LCALA: "Langues et cultures de l'antiquité",
    LCAGR: "Langues et cultures de l'antiquité", DANSE: "Autres enseignements"}
  cle_noms = {'ANGLAIS LV1': 'Anglais', 'ESPAGNOL LV2': 'Espagnol', 'ESPAGNOL LV2 ND': 'Espagnol non débutant',
    'ALLEMAND LV2': 'Allemand', 'ALLEMAND LV2 ND': 'Allemand non débutant', 'LCA LATIN': 'Latin', 'LCA GREC': 'Grec',
    'DANSE': 'Danse'}

  obligatoire = code_modalite == 'O'
  groupe = cle_groupes[cle_gestion.to_sym]
  nom = cle_noms[libelle.to_sym]

  option = Option.find_or_initialize_by(nom: nom, groupe: groupe, modalite: obligatoire ? 'obligatoire' : 'facultative')
  option.save!
  option
end
