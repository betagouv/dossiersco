# frozen_string_literal: true

class RespLegal < ActiveRecord::Base

  belongs_to :dossier_eleve

  before_validation :defini_ville_residence
<<<<<<< HEAD
  before_save :vide_ville_etrangere
  validates :enfants_a_charge, presence: true, if: :priorite_1?

  with_options if: :resp_present? do |resp|
    resp.validate :un_telephone_renseigne?
    resp.validates_presence_of :nom, :prenom, :lien_de_parente, :ville, :pays, :profession
    resp.validates :adresse, presence: true
    resp.validates :code_postal, presence: true, if: :pays_fra?
    resp.validates :communique_info_parents_eleves, inclusion: { in: [true, false] }
  end

  def pays_fra?
    pays == "FRA" && resp_present?
=======
  validate :un_telephone_renseigne?
  validates_presence_of :nom, :prenom, :lien_de_parente, :adresse
  validates :code_postal, presence: true, if: :pays_fra?
  validates :enfants_a_charge, presence: true, if: :priorite_1?

  def pays_fra?
    pays == "FRA"
>>>>>>> ajoute des validations pour les responsables legaux
  end

  def priorite_1?
    priorite == 1
  end

<<<<<<< HEAD
  def resp_present?
    !(nom.blank? && prenom.blank? && priorite == 2) || priorite_1?
  end

=======
>>>>>>> ajoute des validations pour les responsables legaux
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
       tel_portable tel_professionnel email profession enfants_a_charge pays
       communique_info_parents_eleves lien_avec_eleve]
  end

  def un_telephone_renseigne?
    if tel_personnel.blank? && tel_portable.blank? && tel_professionnel.blank?
      errors.add(:telephone, I18n.t(".activerecord.errors.models.resp_legal.pas_de_telephone"), responsable: priorite)
      false
    else
      true
    end
  end

  def moyens_de_communication
    moyens = []
    %i[email tel_personnel tel_professionnel tel_portable].each do |moyen|
      moyens << send(moyen) if send(moyen).present?
    end
    moyens
  end

  def nom_complet
    "#{prenom} #{nom}"
  end

  def defini_ville_residence
    self.ville = ville_etrangere unless ville_etrangere.blank?
  end

<<<<<<< HEAD
  def vide_ville_etrangere
    self.ville_etrangere = ""
  end

=======
>>>>>>> ajoute des validations pour les responsables legaux
end
