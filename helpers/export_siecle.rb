require 'tilt/erb'

def export_xml etablissement, mappings, template
 template = Tilt::ERBTemplate.new("views/export/#{template}.erb")
 personnes = RespLegal.joins(:dossier_eleve).where(dossier_eleves: {etablissement_id: etablissement.id})
 template.render nil, {
   etablissement: etablissement,
   personnes: personnes,
   mappings: mappings
 }
end