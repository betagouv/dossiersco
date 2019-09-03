# frozen_string_literal: true

require "nokogiri"

fichier = ARGV[0]
puts fichier

if fichier
  unless /[[:digit:]]{7}[[:upper:]]PRIVE[[:digit:]]{14}/.match?(fichier)
    puts "Le nom du fichier est du type 0750680GPRIVE2018190626160300.xml (UAI puis PRIVE puis la date du jour et l'heure)"
  end
  aujourdhui = Time.now.strftime("%m%d")
  puts "Le nom du fichier doit contenir la date du jour : #{aujourdhui}" unless fichier.include? aujourdhui

  schema = "./lib/schema_Import_3.1_avec_correction.xsd"
  xsd = Nokogiri::XML::Schema(File.read(schema))
  xml = Nokogiri::XML(File.read(fichier))
  puts "erreur dans le fichier xml : #{xml.errors}" unless xml.errors.empty?
  puts xsd.validate(xml)
end
