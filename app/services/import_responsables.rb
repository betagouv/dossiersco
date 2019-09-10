# frozen_string_literal: true

require "nokogiri"

class ImportResponsables

  def perform(tache)
    xml = Nokogiri::XML(File.read("#{Rails.root}/public/#{tache.fichier}"))

    return if xml.xpath("/BEE_RESPONSABLES/PARAMETRES/UAJ").text != tache.etablissement.uai

    parcours_personnes xml, tache

    met_a_jour_les_dossiers!(tache.etablissement)
  end

  def parcours_personnes(xml, tache)
    xml.xpath("/BEE_RESPONSABLES/DONNEES/PERSONNES/PERSONNE").each do |noeud_personne|
      responsables = RespLegal.par_nom_et_prenom(tache.etablissement,
                                                 noeud_personne.xpath("NOM_DE_FAMILLE").text,
                                                 noeud_personne.xpath("PRENOM").text)

      next if responsables.count > 1
      next ExceptionAucunResponsableLegalTrouve if responsables.count.zero?

      met_a_jour_le_paiement_des_frais!(responsables.first, noeud_personne)
      met_a_jour_la_profession_des_retraites!(responsables.first, noeud_personne)
    end
  end

  def met_a_jour_le_paiement_des_frais!(responsable, noeud)
    id = noeud.attributes["PERSONNE_ID"].value
    noeud.xpath("/BEE_RESPONSABLES/DONNEES/RESPONSABLES/RESPONSABLE_ELEVE[PERSONNE_ID=#{id}]").each do |noeud_responsable|
      paie_frais_scolaires = noeud_responsable.xpath("PAIE_FRAIS_SCOLAIRES").text
      responsable.update(paie_frais_scolaires: paie_frais_scolaires)
    end
  end

  def met_a_jour_la_profession_des_retraites!(responsable, noeud)
    if [
      RespLegal::CODE_PROFESSION_RETRAITES_CADRES_ET_PROFESSIONS_INTERMEDIAIRE,
      RespLegal::CODE_PROFESSION_RETRAITES_EMPLOYES_ET_OUVRIERS
    ].include?(responsable.profession)
      code_profession = noeud.xpath("CODE_PROFESSION").text
      responsable.update(profession: code_profession)
    end
  end

  def met_a_jour_les_dossiers!(etablissement)
    AnalyseurRetourSiecle.analyse_dossiers!(etablissement.dossier_eleve)
  end

end
