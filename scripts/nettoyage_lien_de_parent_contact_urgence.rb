# frozen_string_literal: true

def nettoyage(lien)
  lien.downcase.gsub(/[éêèë]/, "e").gsub(/[àâ]/, "a").tr("-", " ").tr(".", " ")
end

def mere?(contact)
  contact.lien_de_parente == "mere" ||
    contact.lien_de_parente == "maman"
end

def pere?(contact)
  contact.lien_de_parente == "pere" ||
    contact.lien_de_parente == "papa"
end

def fratrie?(contact)
  contact.lien_de_parente == "fratrie" ||
    contact.lien_de_parente == "frere" ||
    contact.lien_de_parente == "demi-frère" ||
    contact.lien_de_parente == "soeur" ||
    contact.lien_de_parente == "sœur"
end

def ascendant?(contact)
  contact.lien_de_parente == "ascendant" ||
    contact.lien_de_parente == "grnad mere" ||
    contact.lien_de_parente == "grand pere" ||
    contact.lien_de_parente == "grand pere paternel" ||
    contact.lien_de_parente == "grand pere maternel" ||
    contact.lien_de_parente == "grand mere" ||
    contact.lien_de_parente == "grand mere paternel" ||
    contact.lien_de_parente == "grand mere maternel" ||
    contact.lien_de_parente == "grand parent" ||
    contact.lien_de_parente == "grands parents" ||
    contact.lien_de_parente == "mamie maternelle" ||
    contact.lien_de_parente == "grand-père et médecin"
end

def autre_membre?(contact)
  contact.lien_de_parente == "autremembredelafamille" ||
    contact.lien_de_parente == "beau pere" ||
    contact.lien_de_parente == "belle mere" ||
    contact.lien_de_parente == "tante" ||
    contact.lien_de_parente == "oncle" ||
    contact.lien_de_parente == "ma niece" ||
    contact.lien_de_parente == "marraine"
end

def educateur?(contact)
  contact.lien_de_parente == "educateur" ||
    contact.lien_de_parente == "Educateurs MDEF Mélan Taninges"
end

def assistante_familliale?(contact)
  contact.lien_de_parente == "ass.famil" ||
    contact.lien_de_parente == "nounou" ||
    contact.lien_de_parente == "baby-sitter de son frere"
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
    puts contact.lien_de_parente
    # contact.update(lien_de_parente: "AUTRE LIEN")
  end
end
