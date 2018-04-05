require 'roo'
require 'roo-xls'

def import_xls fichier
  # chargement du fichier excel affelnet
  xls_document = Roo::Spreadsheet.open fichier

  (xls_document.first_row+1..xls_document.last_row).each do |row|
    colonnes = {sexe: 0, pays_nat: 1, prenom: 6, nom: 4, date_naiss: 9, identifiant: 11,
      ville_naiss_etrangere: 20, commune_naiss: 21, pays_naiss: 22}

    sexe = xls_document.row(row)[colonnes[:sexe]]
    pays_nat = xls_document.row(row)[colonnes[:pays_nat]]
    date_naiss = xls_document.row(row)[colonnes[:date_naiss]].strftime('%Y-%m-%d')
    prenom = xls_document.row(row)[colonnes[:prenom]]
    nom = xls_document.row(row)[colonnes[:nom]]
    identifiant = xls_document.row(row)[colonnes[:identifiant]]
    pays_naiss = xls_document.row(row)[colonnes[:pays_naiss]]
    if pays_naiss == 'FRANCE'
      ville_naiss = xls_document.row(row)[colonnes[:commune_naiss]]
    else
      ville_naiss = xls_document.row(row)[colonnes[:ville_naiss_etrangere]]
    end

    Eleve.create!(
        identifiant: identifiant,
        sexe: sexe,
        nationalite: pays_nat,
        date_naiss: date_naiss,
        prenom: prenom,
        nom: nom,
        pays_naiss: pays_naiss,
        ville_naiss: ville_naiss)
  end
end