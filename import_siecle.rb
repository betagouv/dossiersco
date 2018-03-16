require 'roo'
require 'roo-xls'

# chargement du fichier excel affelnet
xls_document = Roo::Spreadsheet.open 'resources/secrets/elevescomplete_jfo_15mar18.xls'

row = 300

SEXE = 0
puts xls_document.row(1)[SEXE]
puts xls_document.row(row)[SEXE]

PAYS_NAT = 1
puts xls_document.row(1)[PAYS_NAT]
puts xls_document.row(row)[PAYS_NAT]

DATE_NAISS = 9
puts xls_document.row(1)[DATE_NAISS]
puts xls_document.row(row)[DATE_NAISS].split("/").reverse().join("-")

PRENOM = 6
puts xls_document.row(1)[PRENOM]
puts xls_document.row(row)[PRENOM]

NOM = 4
puts xls_document.row(1)[NOM]
puts xls_document.row(row)[NOM]
