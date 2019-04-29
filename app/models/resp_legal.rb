# frozen_string_literal: true

class RespLegal < ActiveRecord::Base

  belongs_to :dossier_eleve

  def meme_adresse(autre_resp_legal)
    return false if autre_resp_legal.nil?

    meme_adresse = true
    %w[adresse code_postal ville].each do |c|
      meme_adresse &&= (self[c] == autre_resp_legal[c])
    end
    meme_adresse
  end

  def equivalentes(valeur1, valeur2)
    (valeur1&.upcase&.gsub(/[[:space:]]/, "")) ==
      (valeur2&.upcase&.gsub(/[[:space:]]/, ""))
  end

  def adresse_inchangee
    return true if adresse_ant.nil? && ville_ant.nil? && code_postal_ant.nil?

    equivalentes(adresse, adresse_ant) &&
      equivalentes(ville, ville_ant) &&
      equivalentes(code_postal, code_postal_ant)
  end

  def self.code_profession_from(libelle)
    codes_profession.each do |code, lib|
      return code.to_s if lib == libelle
    end
    "99"
  end

  def self.codes_profession
    { '99': "", '10': "agriculteur exploitant", '21': "artisan", '22': "commerçant et assimilé",
      '23': "chef d'entreprise de 10 salariés et+", '31': "profession libérale", '33': "cadre de la fonction publique",
      '34': "professeur, profession scientifique", '35': "profession de l'information, des arts et des spectacles",
      '37': "cadre administratif, commercial d'entreprise", '38': "ingénieur, cadre technique d'entreprise",
      '42': "instituteur et assimilé", '43': "profession intermédiaire de la santé et du travail social",
      '44': "Clergé, religieux", '45': "Profession intermédiaire administrative de la fonction publique",
      '46': "Profession intermédiaire administrative et commerciale des entreprises", '47': "Technicien",
      '48': "Contremaître, agent de maîtrise", '52': "Employé civil et agent de service de la fonction publique",
      '53': "Policier, militaire", '54': "Employé administratif d'entreprise", '55': "Employé de commerce",
      '56': "Personnel service direct aux particuliers",
      '62': "Ouvrier qualifié - industrie",
      '63': "Ouvrier qualifié - artisanal",
      '65': "Ouvrier qualifié - magasinage",
      '67': "Ouvrier non qualifié de type industriel",
      '68': "Ouvrier non qualifié de type artisanal",
      '69': "Ouvrier agricole", '71': "Retraité agriculteur exploitant",
      '72': "Retraité artisan, commerçant, chef d'entreprise", '73': "Retraité cadre, profession interm édiaire",
      '76': "Retraité employé, ouvrier",
      '85': "Personne sans activité professionnelle < 60 ans",
      '86': "Personne sans activité professionnelle > 60 ans" }
  end

  def self.identites
    %w[lien_de_parente prenom nom adresse code_postal ville tel_personnel
       tel_portable email profession enfants_a_charge
       communique_info_parents_eleves lien_avec_eleve]
  end

end
