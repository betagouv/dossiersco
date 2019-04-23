# frozen_string_literal: true

require 'tilt/erb'

def export_xml(etablissement, mappings, template)
  template = Tilt::ERBTemplate.new("views/export/#{template}.erb")
  personnes = RespLegal.joins(:dossier_eleve).where(dossier_eleves: { etablissement_id: etablissement.id })
  template.render nil,
                  etablissement: etablissement,
                  personnes: personnes,
                  mappings: mappings
end

def export_xml_tous_les_champs(etablissement, template)
  mappings = [Mapping.new(:identifiant, 'ID_NATIONAL'),
              Mapping.new(:nom, 'NOM_DE_FAMILLE'),
              Mapping.new(:prenom, 'PRENOM'),
              Mapping.new(:date_naiss, 'DATE_NAISS')]
  export_xml etablissement, mappings, template
end

class Mapping
  attr_accessor :source, :cible
  def initialize(source, cible)
    @source = source
    @cible = cible
  end
end
