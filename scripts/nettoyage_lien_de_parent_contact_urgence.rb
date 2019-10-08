# frozen_string_literal: true

def nettoyage(lien)
  lien.downcase.gsub(/[éêèë]/, "e").gsub(/[àâ]/, "a").tr("-", " ").tr(".", " ").strip
end

def mere?(contact)
  contact.lien_de_parente == "mere" ||
    contact.lien_de_parente == "la mere" ||
    contact.lien_de_parente == "mere ou pere" ||
    contact.lien_de_parente == "maman"
end

def pere?(contact)
  contact.lien_de_parente == "pere" ||
    contact.lien_de_parente == "pere \"adoptif\"" ||
    contact.lien_de_parente == "papa"
end

def fratrie?(contact)
  ["fratrie", "frere", "frere aine", "frere aîne", "frere (aine)", "frere majeur", "grand frere", "demi-frère",
   "enfant", "frere (aine)", "frere / parrain civil", "grand soeur", "grand frere", "grande soeur 1", "grande sœur",
   "sa soeur", "le frere", "soeur", "sœur (aînee)", "sœur aînee", "sœurs", "seur", "fille", "fils", "soeur (majeure)",
   "soeur ainee", "soeurs", "grande soeur", "sœur"].include?(contact.lien_de_parente)
end

def ascendant?(contact)
  [
    "ascendant", "grnad mere", "grand pere", "g parents", "gd mere", "gran mere", "grand   mere", "grand  mere", "grand meere",
    "grand mere maternelles", "grand mere sebahi eliane", "grand parents maternels", "grand partent", "grand pere et grand mere",
    "grand pere et medecin", "grand_mere", "grande mere", "grande pere", "grandmere", "grands  parents", "grands parentd",
    "grands parents maternelle s", "grands pere", "grang mere", "granp pere", "grend mere", "mamy", "papy", "pere mamie", "sa mamie",
    "grand  pere", "grand pere paternel", "grand pere maternel", "grand mere", "grand  mere",
    "grands parentd", "grand mere paternel", "grand mere paternelle", "grand mere maternel", "grand mere,soeur",
    "grand mere maternelle", "gd mere maternelle", "grand parent", "grands parents", "grand parents", "grands parents maternels",
    "grands parents paternels", "mamie maternelle", "mamie", "mami", "papi", "compagne du pere", "grand pere et médecin"
  ].include?(contact.lien_de_parente)
end

def autre_membre?(contact)
  ["autremembredelafamille", "autre membre de la famille", "grands parents de coeur", "beau pere", "beau  pere",
   "beau   pere", "beau papa", "beau parent", "beau peere", "beau_pere", "beaux pere", "belle maman", "belle mere / marraine",
   "marie", "bo pere", "beau papa", "compagnon de la mere", "concubin", "compagnon de la mere", "epoux de la mere", "belle mere",
   "conjointe du pere", "conjoint de la mere", "compagnon mere", "tante", "parente", "parents", "oncle / tante",
   "oncle et tante", "oncle maternel", "oncle paternel", "oncle/ tante", "neveu", "niece", "marainne", "la tanre", "l oncle",
   "grande cousine", "grand oncle", "sa tante", "sa tante maternelle", "sa tatiee", "son oncle", "compagnon mere", "conjoint de la mere",
   "cousin", "cousine et voisine", "epoux de la mere", "demi frere", "demi soeur", "tant", "tante et maraine",
   "tante maternelle", "tante paternelle", "tata et tonon", "tati", "tente", "tata", "tatie", "la tante", "la tente",
   "grande tante", "oncle", "tonton", "ma niece", "cousine", "famille", "marraine", "maraine", "parrain"].include?(contact.lien_de_parente)
end

def educateur?(contact)
  contact.lien_de_parente == "educateur" ||
    contact.lien_de_parente == "educateurs mdef melan taninges" ||
    contact.lien_de_parente == "educatrice"
end

def assistante_familliale?(contact)
  [
    "ass.famil", "ass  famil", "assistante maternelle", "nounou", "garde domicile", "nounou de son frere", "nourrice",
    "nourrrice", "assistante familiale", "assistant familial", "assistante familial", "assistante maternelle de la famille"
  ].include?(contact.lien_de_parente)
end

def tuteur?(contact)
  contact.lien_de_parente == "tuteur" ||
    contact.lien_de_parente == "titeur" ||
    contact.lien_de_parente == "tutrice"
end

def aide_sociale?(contact)
  contact.lien_de_parente == "aidesocialeal'enfance" ||
    contact.lien_de_parente == "assistante sociale" ||
    contact.lien_de_parente == "suivi social"
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
    contact.update(lien_de_parente: "AUTRE LIEN")
  end
end
