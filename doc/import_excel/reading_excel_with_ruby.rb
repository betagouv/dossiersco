# frozen_string_literal: true

require "roo"
require "roo-xls"

# chargement du fichier excel affelnet
xls_document = Roo::Spreadsheet.open "./affelnet.xls"

puts xls_document.info

puts xls_document.sheets

puts xls_document.last_row

puts xls_document.last_column

puts xls_document.row(4)

puts xls_document.column("H")
puts xls_document.column(8)

puts xls_document.cell(10, 10)

xls_document.each(nom_elv: "nom_elv", prenom_elv: "prenom_elv") do |row|
  puts row
end

puts xls_document.parse(nom_elv: "nom_elv", prenom_elv: "prenom_elv")
