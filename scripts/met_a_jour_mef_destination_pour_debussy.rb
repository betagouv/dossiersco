# frozen_string_literal: true

etablissement = Etablissement.find_by(uai: "0931434D")

file = File.read("#{Rails.root}/lib/eleves_debussy_mef_destination.xml")
xml = Nokogiri::XML(file)

xml.xpath("//ELEVE").each do |noeud_eleve|
  ine = noeud_eleve.xpath("ID_NATIONAL").text
  if ine.blank?
    puts "NEXT ine vide"
    next
  end

  dossier = DossierEleve.joins(:eleve).where("eleves.identifiant = ?", ine).first
  if dossier.blank?
    puts "next, dossier non trouvé pour #{ine}"
    next
  end

  cm2 = Mef.find_by(etablissement: etablissement, libelle: "CM2")
  if dossier.mef_destination != cm2
    puts "suivant car mef destination n'est pas CM2"
    next
  end


  code_mef_destination = noeud_eleve.xpath("CODE_MEF").text
  mef_destination = Mef.find_by(etablissement: etablissement, code: code_mef_destination)
  puts "mise à jour #{ine} de mef destination #{dossier.mef_destination_id} pour #{mef_destination.id}"
  dossier.update(mef_destination: mef_destination)

  code_mef_an_dernier = noeud_eleve.xpath("SCOLARITE_AN_DERNIER/CODE_MEF").text
  puts "mise à jour #{ine} de mef an dernier #{dossier.mef_an_dernier} pour #{code_mef_an_dernier}"
  dossier.update(mef_an_dernier: code_mef_an_dernier)
end
