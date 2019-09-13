
etablissement = Etablissement.find_by(uai: "0931434D")

file = File.read("#{Rails.root}/lib/eleves_debussy_mef_destination.xml")
xml = Nokogiri::XML(file)

xml.xpath("//ELEVE").each do |noeud_eleve|
  ine = noeud_eleve.xpath("ID_NATIONAL").text
  next if ine.blank?
  code_mef_destination = noeud_eleve.xpath("CODE_MEF").text
  code_mef_an_dernier = noeud_eleve.xpath("SCOLARITE_AN_DERNIER/CODE_MEF").text
  puts "ine: #{ine} code_mef_destination: #{code_mef_destination} code_mef_and_dernier: #{code_mef_an_dernier}"

  mef_destination = Mef.find_by(etablissement: etablissement, code: code_mef_destination)
  mef_an_dernier = Mef.find_by(etablissement: etablissement, code: code_mef_an_dernier)
  dossier = DossierEleve.joins(:eleve).where("eleves.identifiant = ?", ine).first

  puts "dossier : #{dossier.inspect} mef destination : #{mef_destination.inspect} mef_an_dernier: #{mef_an_dernier.inspect}"
end
