# frozen_string_literal: true

ContactUrgence.where(tel_principal: [nil, ""], tel_secondaire: [nil, ""]).delete_all

ContactUrgence.all.each do |contact|
  contact.update(lien_de_parente: nettoyage(contact.lien_de_parente))

  if mere?(contact)
    contact.update(lien_de_parente: "MERE")
  elsif pere?(contact)
    contact.update(lien_de_parente: "PERE")
  elsif fratrie?(contact)
    contact.update(lien_de_parente: "FRATRIE")
  elsif ascendant?(contact)
    contact.update(lien_de_parente: "ASCENDANT")
  elsif autre_membre?(contact)
    contact.update(lien_de_parente: "AUTRE MEMBRE DE LA FAMILLE")
  elsif educateur?(contact)
    contact.update(lien_de_parente: "EDUCATEUR")
  elsif assistante_familliale?(contact)
    contact.update(lien_de_parente: "ASS. FAMIL")
  elsif tuteur?(contact)
    contact.update(lien_de_parente: "TUTEUR")
  elsif aide_sociale?(contact)
    contact.update(lien_de_parente: "AIDE SOCIALE A L'ENFANCE")
  elsif eleve?(contact)
    contact.update(lien_de_parente: "ELEVE")
  else
    puts contact.lien_de_parent
    # contact.update(lien_de_parente: "AUTRE LIEN")
  end
end

def nettoyage(lien)
  lien.downcase.gsub(/[éêèë]/, "e").gsub(/[àâ]/, "a")
end

def mere?(contact)
  contact.lien_de_parente == "mere"
end

def pere?(contact)
  contact.lien_de_parente == "pere"
end

def fratrie?(contact)
  contact.lien_de_parente == "fratrie"
end

def ascendant?(contact)
  contact.lien_de_parente == "ascendant"
end

def autre_membre?(contact)
  contact.lien_de_parente == "autremembredelafamille"
end

def educateur?(contact)
  contact.lien_de_parente == "educateur"
end

def assistante_familliale?(contact)
  contact.lien_de_parente == "ass.famil"
end

def tuteur?(contact)
  contact.lien_de_parente == "tuteur"
end

def aide_sociale?(contact)
  contact.lien_de_parente == "aidesocialeal'enfance"
end

def eleve?(contact)
  contact.lien_de_parente == "eleve"
end
