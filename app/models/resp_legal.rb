# frozen_string_literal: true

class RespLegal < ActiveRecord::Base

  belongs_to :dossier_eleve

  before_validation :defini_ville_residence
  before_save :vide_ville_etrangere
  validates :enfants_a_charge, presence: true, if: :priorite_1?

  with_options if: :resp_present? do |resp|
    resp.validate :un_telephone_renseigne?
    resp.validates_presence_of :nom, :prenom, :lien_de_parente, :ville, :pays, :profession
    resp.validates :adresse, presence: true
    resp.validates :code_postal, presence: true, if: :pays_fra?
    resp.validates :communique_info_parents_eleves, inclusion: { in: [true, false] }
  end

  CODE_PARENTE = {
    "MERE": 10,
    "PERE": 20,
    "FRATRIE": 37,
    "ASCENDANT": 38,
    "AUTRE MEMBRE DE LA FAMILLE": 39,
    "EDUCATEUR": 41,
    "ASS. FAMIL": 42,
    "TUTEUR": 50,
    "AIDE SOCIALE A L'ENFANCE": 51,
    "ELEVE": 70,
    "AUTRE LIEN": 90
  }.freeze

  CODE_PROFESSION_RETRAITES_CADRES_ET_PROFESSIONS_INTERMEDIAIRE = "73"
  CODE_PROFESSION_RETRAITES_EMPLOYES_ET_OUVRIERS = "76"

  scope :par_nom_et_prenom, lambda { |etablissement, nom, prenom|
    where(nom: nom, prenom: prenom).joins(:dossier_eleve) .where("dossier_eleves.etablissement_id = ?", etablissement.id)
  }

  def pays_fra?
    pays == "FRA" && resp_present?
  end

  def priorite_1?
    priorite == 1
  end

  def resp_present?
    !(nom.blank? && prenom.blank? && priorite == 2) || priorite_1?
  end

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

  def vide_ville_etrangere
    self.ville_etrangere = ""
  end

  def tel_professionnel_siecle
    tel_professionnel.gsub(/\d*/).first
  end

  def ligne1_adresse_siecle
    lignes_adresses[0]
  end

  def ligne2_adresse_siecle
    lignes_adresses[1]
  end

  private

  def lignes_adresses
    return [adresse, nil] if adresse.length <= 38

    [adresse[0, 38], adresse[38..-1]]
  end

end
