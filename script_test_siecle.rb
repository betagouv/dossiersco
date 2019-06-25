require 'nokogiri'

fichier = ARGV[0]
puts fichier

if fichier
  schema = "./doc/import_prive/schema_Import_3.1.xsd"
  xsd = Nokogiri::XML::Schema(File.read(schema))
  xml = Nokogiri::XML(File.read(fichier))
  puts xsd.validate(xml)
end
