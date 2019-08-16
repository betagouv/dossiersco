# frozen_string_literal: true

require "nokogiri"

class ImportNomenclature

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)

    met_a_jour_les_mef!(xml, tache.etablissement)
    met_a_jour_les_options_pedagogiques!(xml, tache.etablissement)
    met_a_jour_les_mef_options_pedagogiques!(xml, tache.etablissement)
    met_a_jour_les_rangs_options!(xml, tache.etablissement)
  end

  def met_a_jour_les_mef!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/MEFS/MEF/LIBELLE_LONG").each do |element|
      Mef.find_by(etablissement: etablissement, libelle: element.text)&.update(code: element.parent.attributes["CODE_MEF"])
    end
  end

  def met_a_jour_les_options_pedagogiques!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/MATIERES/MATIERE/CODE_GESTION").each do |element|
      code_matiere = element.parent.attributes["CODE_MATIERE"]
      option = OptionPedagogique.find_by(etablissement: etablissement, code_matiere: element.text)
      if option
        option.update(code_matiere_6: code_matiere)
      else
        OptionPedagogique.create!(
          etablissement: etablissement,
          nom: element.parent.xpath("LIBELLE_COURT").text,
          libelle: element.parent.xpath("LIBELLE_LONG").text,
          code_matiere: element.parent.xpath("CODE_GESTION").text,
          code_matiere_6: element.parent.attributes["CODE_MATIERE"]
        )
      end
    end
  end

  def met_a_jour_les_mef_options_pedagogiques!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/PROGRAMMES/PROGRAMME").each do |programme|
      code_matiere = programme.xpath("CODE_MATIERE").text
      code_mef = programme.xpath("CODE_MEF").text
      code_modalite_elect = programme.xpath("CODE_MODALITE_ELECT").text

      mef = Mef.find_by(etablissement: etablissement, code: code_mef)
      option_pedagogique = OptionPedagogique.find_by(etablissement: etablissement, code_matiere_6: code_matiere)
      MefOptionPedagogique.find_by(mef: mef, option_pedagogique: option_pedagogique, code_modalite_elect: [nil, "", "S"])&.update(code_modalite_elect: code_modalite_elect)
    end
  end

  def met_a_jour_les_rangs_options!(xml, etablissement)
    xml.xpath("/BEE_NOMENCLATURES/DONNEES/OPTIONS_OBLIGATOIRES/OPTION_OBLIGATOIRE").each do |programme|
      code_matiere = programme.xpath("CODE_MATIERE").text
      code_mef = programme.xpath("CODE_MEF").text
      rang_option = programme.xpath("RANG_OPTION").text

      mef = Mef.find_by(etablissement: etablissement, code: code_mef)
      option_pedagogique = OptionPedagogique.find_by(etablissement: etablissement, code_matiere_6: code_matiere)
      MefOptionPedagogique.find_by(mef: mef, option_pedagogique: option_pedagogique)&.update(rang_option: rang_option)
    end
  end

end
