# frozen_string_literal: true

def nettoyage(lien)
  lien.downcase.gsub(/[éêèë]/, "e").gsub(/[àâ]/, "a").tr("-", " ").tr(".", " ").strip
end

def mere?(contact)
  contact.lien_de_parente == "mere" ||
    contact.lien_de_parente == "mere ou pere" ||
    contact.lien_de_parente == "maman"
end

def pere?(contact)
  contact.lien_de_parente == "pere" ||
    contact.lien_de_parente == "papa"
end

def fratrie?(contact)
  contact.lien_de_parente == "fratrie" ||
    contact.lien_de_parente == "frere" ||
    contact.lien_de_parente == "frere aine" ||
    contact.lien_de_parente == "frere aîne" ||
    contact.lien_de_parente == "frere majeur" ||
    contact.lien_de_parente == "demi-frère" ||
    contact.lien_de_parente == "soeur" ||
    contact.lien_de_parente == "grande soeur" ||
    contact.lien_de_parente == "sœur"
end

def ascendant?(contact)
  contact.lien_de_parente == "ascendant" ||
    contact.lien_de_parente == "grnad mere" ||
    contact.lien_de_parente == "grand pere" ||
    contact.lien_de_parente == "grand  pere" ||
    contact.lien_de_parente == "grand pere paternel" ||
    contact.lien_de_parente == "grand pere maternel" ||
    contact.lien_de_parente == "grand mere" ||
    contact.lien_de_parente == "grand mere paternel" ||
    contact.lien_de_parente == "grand mere paternelle" ||
    contact.lien_de_parente == "grand mere maternel" ||
    contact.lien_de_parente == "grand mere,soeur" ||
    contact.lien_de_parente == "grand mere maternelle" ||
    contact.lien_de_parente == "gd mere maternelle" ||
    contact.lien_de_parente == "grand parent" ||
    contact.lien_de_parente == "grands parents" ||
    contact.lien_de_parente == "grand parents" ||
    contact.lien_de_parente == "grands parents maternels" ||
    contact.lien_de_parente == "grands parents paternels" ||
    contact.lien_de_parente == "mamie maternelle" ||
    contact.lien_de_parente == "mamie" ||
    contact.lien_de_parente == "mami" ||
    contact.lien_de_parente == "papi" ||
    contact.lien_de_parente == "compagne du pere" ||
    contact.lien_de_parente == "grand pere et médecin"
end

def autre_membre?(contact)
  contact.lien_de_parente == "autremembredelafamille" ||
  contact.lien_de_parente == "autre membre de la famille" ||
  contact.lien_de_parente == "grands parents de coeur" ||
    contact.lien_de_parente == "beau pere" ||
    contact.lien_de_parente == "beau  pere" ||
    contact.lien_de_parente == "beau   pere" ||
    contact.lien_de_parente == "beau papa" ||
    contact.lien_de_parente == "beau parent" ||
    contact.lien_de_parente == "beau peere" ||
    contact.lien_de_parente == "beau_pere" ||
    contact.lien_de_parente == "beaux pere" ||
    contact.lien_de_parente == "belle maman" ||
    contact.lien_de_parente == "belle mere / marraine" ||
    contact.lien_de_parente == "bo pere" ||
    contact.lien_de_parente == "beau papa" ||
    contact.lien_de_parente == "compagnon de la mere" ||
    contact.lien_de_parente == "concubin" ||
    contact.lien_de_parente == "compagnon de la mere" ||
    contact.lien_de_parente == "belle mere" ||
    contact.lien_de_parente == "conjointe du pere" ||
    contact.lien_de_parente == "tante" ||
    contact.lien_de_parente == "tata" ||
    contact.lien_de_parente == "tatie" ||
    contact.lien_de_parente == "la tante" ||
    contact.lien_de_parente == "la tente" ||
    contact.lien_de_parente == "grande tante" ||
    contact.lien_de_parente == "oncle" ||
    contact.lien_de_parente == "tonton" ||
    contact.lien_de_parente == "ma niece" ||
    contact.lien_de_parente == "cousine" ||
    contact.lien_de_parente == "famille" ||
    contact.lien_de_parente == "marraine" ||
    contact.lien_de_parente == "maraine" ||
    contact.lien_de_parente == "parrain"
end

def educateur?(contact)
  contact.lien_de_parente == "educateur" ||
    contact.lien_de_parente == "Educateurs MDEF Mélan Taninges" ||
    contact.lien_de_parente == "educatrice"
end

def assistante_familliale?(contact)
  contact.lien_de_parente == "ass.famil" ||
    contact.lien_de_parente == "ass  famil" ||
    contact.lien_de_parente == "assistante maternelle" ||
    contact.lien_de_parente == "nounou" ||
    contact.lien_de_parente == "assistante familiale" ||
    contact.lien_de_parente == "assistante familial" ||
    contact.lien_de_parente == "assistante maternelle de la famille"
end

def tuteur?(contact)
  contact.lien_de_parente == "tuteur"
end

def aide_sociale?(contact)
  contact.lien_de_parente == "aidesocialeal'enfance" ||
    contact.lien_de_parente == "assistante sociale"
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
