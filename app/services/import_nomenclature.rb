# frozen_string_literal: true

require "nokogiri"

class ImportNomenclature

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)

    met_a_jour_les_mef!(xml, tache.etablissement)
    met_a_jour_les_options_pedagogiques!(xml, tache.etablissement)
  end

  def met_a_jour_les_mef!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/MEFS/MEF/LIBELLE_LONG").each do |element|
      Mef.find_by(etablissement: etablissement, libelle: element.text)&.update(code: element.parent.attributes["CODE_MEF"])
    end
  end

  def met_a_jour_les_options_pedagogiques!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/MATIERES/MATIERE/CODE_GESTION").each do |element|
      code_matiere = element.parent.attributes["CODE_MATIERE"]
      OptionPedagogique.find_by(etablissement: etablissement, code_matiere: element.text)&.update(code_matiere_6: code_matiere)
    end
  end

end
