# frozen_string_literal: true

class Etablissement < ActiveRecord::Base

  has_many :dossier_eleve, dependent: :destroy
  has_many :agent, dependent: :destroy
  has_many :tache_import, dependent: :destroy
  has_many :pieces_attendues, dependent: :destroy
  has_many :modele, dependent: :destroy
  has_many :mef, dependent: :destroy
  has_many :options_pedagogiques, dependent: :destroy
  has_many :regimes_sortie, dependent: :destroy
  has_many :fichier_a_telechargers, dependent: :destroy

  mount_uploader :reglement_demi_pension, FichierEtablissementUploader

  validates :code_postal, length: { is: 5 }, numericality: { only_integer: true }, allow_blank: true
  validates :uai, presence: true

  def classes
    dossier_eleve.collect(&:eleve).collect(&:classe_ant).reject(&:nil?).uniq
  end

  def niveaux
    dossier_eleve.collect(&:eleve).collect(&:niveau_classe_ant).reject(&:nil?).uniq
  end

  def departement
    code_postal.present? ? code_postal[0..1] : ""
  end

  def purge_dossiers_eleves!
    eleves = dossier_eleve.all.map(&:eleve)
    dossier_eleve.destroy_all
    eleves.map(&:destroy)
    tache_import.destroy_all
  end

  def email_chef
    service = EnregistrementPremierAgentService.new
    service.construit_email_chef_etablissement(uai)
  end

end
