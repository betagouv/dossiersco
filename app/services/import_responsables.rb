# frozen_string_literal: true

require "nokogiri"

class ImportResponsables

  def perform(tache)
    xml = Nokogiri::XML(File.read("#{Rails.root}/public/#{tache.fichier}"))

    xml.xpath("/BEE_RESPONSABLES/DONNEES/PERSONNES/PERSONNE").each do |noeud_personne|
      nom = noeud_personne.xpath("NOM_DE_FAMILLE").text
      prenom = noeud_personne.xpath("PRENOM").text

      responsables = RespLegal.par_nom_et_prenom(tache.etablissement, nom, prenom)

      raise ExceptionPlusieursResponsablesLegauxTrouve if responsables.count > 1
      next ExceptionAucunResponsableLegalTrouve if responsables.count.zero?

      met_a_jour_le_paiement_des_frais!(responsables.first, noeud_personne)
    end
  end

  def met_a_jour_le_paiement_des_frais!(responsable, noeud)
    id = noeud.attributes["PERSONNE_ID"].value
    noeud.xpath("/BEE_RESPONSABLES/DONNEES/RESPONSABLES/RESPONSABLE_ELEVE[PERSONNE_ID=#{id}]").each do |noeud_responsable|
      paie_frais_scolaires = noeud_responsable.xpath("PAIE_FRAIS_SCOLAIRES").text
      responsable.update(paie_frais_scolaires: paie_frais_scolaires)
    end
  end

end
