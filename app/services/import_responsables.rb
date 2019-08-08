# frozen_string_literal: true

require "nokogiri"

class ImportResponsables

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)

    met_a_jour_les_professions!(xml, tache.etablissement)
  end

  def met_a_jour_les_professions!(xml, etablissement)
    xml.xpath("/BEE_RESPONSABLES/DONNEES/PERSONNES/PERSONNE").each do |personne|
      nom = personne.xpath("NOM_DE_FAMILLE").text
      prenom = personne.xpath("PRENOM").text

      responsables = RespLegal.where(nom: nom, prenom: prenom).joins(:dossier_eleve).where("dossier_eleves.etablissement_id = ?", etablissement.id)
      raise ExceptionPlusieursResponsablesLegauxTrouve if responsables.count > 1
      raise ExceptionAucunResponsableLegalTrouve if responsables.count.zero?
    end
  end

end
