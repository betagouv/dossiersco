
PRENOMS_MASCULINS = <<EOF
- daniel
- olivier
- bilal
- laurent
EOF

PRENOMS_FEMININS = <<EOF
- chantal
- amina
- angélique
EOF

def madame?(prenom)
  YAML.load(PRENOMS_FEMININS).include?(prenom)
end

def monsieur?(prenom)
  YAML.load(PRENOMS_MASCULINS).include?(prenom)
end

ContactUrgence.where(civilite: nil).sample(10).each do |contact_sans_civilite|
  prenom = contact_sans_civilite.prenom&.downcase || ""

  if monsieur?(prenom)
    puts "#{prenom} : monsieur 1"
    #contact_sans_civilite.update(civilite: 1)
  elsif madame?(prenom)
    puts "#{prenom} : madame 2"
    #contact_sans_civilite.update(civilite: 2)
  else
    puts "prenom #{prenom} non trouvé"
  end

end


