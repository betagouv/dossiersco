# frozen_string_literal: true

require "nokogiri"

class ImportNomenclature

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/MEFS/MEF/LIBELLE_LONG").each do |element|
      Mef.find_by(etablissement: tache.etablissement, libelle: element.text)&.update(code: element.parent.attributes["CODE_MEF"])
    end
  end

end
