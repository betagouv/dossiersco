# frozen_string_literal: true

class Eleve < ActiveRecord::Base

  has_one :dossier_eleve, dependent: :destroy
  has_many :demande
  has_many :abandon
  belongs_to :montee, required: false
  delegate :email_resp_legal_1, to: :dossier_eleve

  def self.par_authentification(identifiant, jour, mois, annee)
    identifiant = identifiant.gsub(/[^[:alnum:]]/, "").upcase
    date_naissance = "#{annee}-#{format('%02d', mois.to_i)}-#{format('%02d', jour.to_i)}"
    find_by(identifiant: identifiant, date_naiss: date_naissance)
  end

  def self.creation_ou_retrouve_par(identifiant)
    find_or_initialize_by(identifiant: identifiant.gsub(/[^[:alnum:]]/, "").upcase)
  end

  def obligatoire(options_du_groupe)
    options_du_groupe.map do |options|
      {
        label: options.first.groupe,
        name: options.first.groupe,
        type: "radio",
        options: options.collect(&:nom),
        checked: options_du_groupe_demandees.size == 1 ? options_du_groupe_demandees[0] : ""
      }
    end
  end

  def options_du_groupe_demandees(options, demande)
    noms_options_du_groupe = options.collect(&:nom)
    noms_demandes = demande.map(&:option).map(&:nom)
    noms_demandes & noms_options_du_groupe
  end

  def options_demandees
    demande.map(&:option)
  end

  def options_abandonnees
    abandon.map(&:option)
  end

  def annee_de_naissance
    date_naiss.split("-")[0]
  end

  def mois_de_naissance
    date_naiss.split("-")[1]
  end

  def jour_de_naissance
    date_naiss.split("-")[2]
  end

  def obligatoire_sans_choix(options_du_groupe)
    options_du_groupe.map do |options|
      {
        name: options.first.nom,
        label: options.first.groupe,
        type: "hidden"
      }
    end
  end

end
