# frozen_string_literal: true

require "nokogiri"

fichier = ARGV[0]
puts fichier

if fichier
  if fichier !~ /[[:digit:]]{7}[[:upper:]]PRIVE[[:digit:]]{14}/ then
    puts "Le nom du fichier est du type 0750680GPRIVE2018190626160300.xml (UAI puis PRIVE puis la date du jour et l'heure)"
  end
  aujourdhui = Time.now.strftime("%y%m%d")
  if !fichier.include? aujourdhui then
    puts "Le nom du fichier doit contenir la date du jour : #{aujourdhui}"
  end

  schema = "./doc/import_prive/schema_Import_3.1.xsd"
  xsd = Nokogiri::XML::Schema(File.read(schema))
  xml = Nokogiri::XML(File.read(fichier))
  puts xsd.validate(xml)
end
