# frozen_string_literal: true

class ImportEleves

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)

    met_a_jour_eleves!(xml)
  end

  def met_a_jour_eleves!(xml)
    xml.xpath("/BEE_ELEVES/DONNEES/ELEVES/ELEVE").each do |noeud_eleve|
      Eleve.find_by(identifiant: noeud_eleve.xpath("ID_NATIONAL").text)&.dossier_eleve&.update(
        mef_an_dernier: extrait_le_code_mef(noeud_eleve),
        division_an_dernier: extrait_la_precedente_division(noeud_eleve),
        division: extrait_division_courante(noeud_eleve)
      )
    end
  end

  def extrait_le_code_mef(noeud)
    noeud.xpath("SCOLARITE_AN_DERNIER/CODE_MEF").text
  end

  def extrait_la_precedente_division(noeud)
    noeud.xpath("SCOLARITE_AN_DERNIER/CODE_STRUCTURE").text
  end

  def extrait_division_courante(noeud)
    id = noeud.attributes["ELEVE_ID"]
    noeud.xpath("/BEE_ELEVES/DONNEES/STRUCTURES/STRUCTURES_ELEVE[@ELEVE_ID='#{id}']/STRUCTURE/CODE_STRUCTURE").text
  end

end
