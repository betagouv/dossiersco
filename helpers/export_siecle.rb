require 'tilt/erb'

def export_xml etablissement
  template = Tilt::ERBTemplate.new('views/export/export_xml.erb')
  template.render nil, etablissement: etablissement
end
