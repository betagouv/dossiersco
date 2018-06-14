require 'tilt/erb'

def export_xml etablissement
  template = Tilt::ERBTemplate.new('views/export/export_xml.erb')
  personnes = RespLegal.joins(:dossier_eleve).where(dossier_eleves: {etablissement_id: etablissement.id})
  template.render nil, {etablissement: etablissement, personnes: personnes}
end
