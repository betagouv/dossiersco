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

  #  TODO: déplacer cette méthode dans dossier
  def self.creation_ou_retrouve_par(identifiant)
    find_or_initialize_by(identifiant: identifiant.gsub(/[^[:alnum:]]/, "").upcase)
  end

  def obligatoire(options_du_groupe)
    options_du_groupe.map do |options|
      noms_options_du_groupe = options.collect(&:nom)
      noms_demandes = demande.map(&:option).map(&:nom)
      options_du_groupe_demandees = noms_demandes & noms_options_du_groupe
      {
        label: options.first.groupe,
        name: options.first.groupe,
        type: "radio",
        options: options.collect(&:nom),
        checked: options_du_groupe_demandees.size == 1 ? options_du_groupe_demandees[0] : ""
      }
    end
  end

  def options_demandees
    demande.map(&:option)
  end

  def options_abandonnees
    abandon.map(&:option)
  end

  def facultative(options_du_groupe)
    options_du_groupe.flat_map do |options|
      options.map do |option|
        {
          name: option.nom,
          label: option.groupe,
          type: "check",
          condition: options_demandees.include?(option),
          desc: option.nom_et_info
        }
      end
    end
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
