# frozen_string_literal: true

require "nokogiri"

premier_fichier = './doc/analyse_nomenclature/Nomenclature-2018-19.xml'
deuxieme_fichier = './doc/analyse_nomenclature/Nomenclature-2019-20.xml'

puts "---8<" + "-" * 30

puts "Début de comparaison des fichiers #{premier_fichier} et #{deuxieme_fichier}"

premier_xml = Nokogiri::XML(File.read(premier_fichier))
deuxieme_xml = Nokogiri::XML(File.read(deuxieme_fichier))

mefs_deuxieme = deuxieme_xml.xpath('/BEE_NOMENCLATURES/DONNEES/MEFS/MEF')
codes_mef_deuxieme = mefs_deuxieme.map{|e| e["CODE_MEF"]}
libelles_long_mef_deuxieme = mefs_deuxieme.map{|e| e.xpath("LIBELLE_LONG").text}

premier_xml.xpath('/BEE_NOMENCLATURES/DONNEES/MEFS/MEF').each do |mef|
  index = codes_mef_deuxieme.index(mef["CODE_MEF"])
  libelle_long = mef.xpath("LIBELLE_LONG").text

  if index && index >= 0
    libelle_long_deuxieme = mefs_deuxieme[index].xpath("LIBELLE_LONG").text
    unless libelle_long == libelle_long_deuxieme
      puts "même code mais libellé différents : 18-19 #{libelle_long}"
      puts "                                    19-20 #{libelle_long_deuxieme}"
    end
  else
    index_libelle_long = libelles_long_mef_deuxieme.index(libelle_long)
    if index_libelle_long && index_libelle_long >= 0
      puts "libellé long trouvé #{libelle_long}"
    else
      puts "code et libellé non trouvé dans le fichier 19-20 code : #{mef['CODE_MEF']}, libelle : #{libelle_long}"
    end
  end
end

puts "---8<" + "-" * 30


