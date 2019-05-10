# frozen_string_literal: true

class Eleve < ActiveRecord::Base

  has_one :dossier_eleve, dependent: :destroy
  has_many :demande
  has_many :abandon
  belongs_to :montee, required: false
  delegate :email_resp_legal_1, to: :dossier_eleve

  def self.par_authentification(identifiant, jour, mois, annee)
    identifiant = identifiant.gsub(/[^[:alnum:]]/, "").upcase
    date_naissance = "#{annee}-#{"%02d" % mois}-#{"%02d" % jour}"
    find_by(identifiant: identifiant, date_naiss: date_naissance)
  end

  def self.creation_ou_retrouve_par(identifiant)
    find_or_initialize_by(identifiant: identifiant.gsub(/[^[:alnum:]]/, "").upcase)
  end

  def genere_demandes_possibles
    return unless montee.present?

    options_par_groupe = montee.demandabilite.map(&:option).group_by(&:groupe)
    groupes_obligatoires = []
    groupes_facultatives = []
    groupes_obligatoires_sans_choix = []
    options_par_groupe.each do |_, options|
      if options.first.modalite == "obligatoire"
        if options.size == 1
          groupes_obligatoires_sans_choix << options
        else
          groupes_obligatoires << options
        end
      elsif options.first.modalite == "facultative"
        groupes_facultatives << options
      end
    end
    obligatoire(groupes_obligatoires) + facultative(groupes_facultatives) + obligatoire_sans_choix(groupes_obligatoires_sans_choix)
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

  def annee_de_naissance
    date_naiss.split("-")[0]
  end

  def mois_de_naissance
    date_naiss.split("-")[1]
  end

  def jour_de_naissance
    date_naiss.split("-")[2]
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

  def genere_abandons_possibles
    return unless montee.present?

    noms_options = option.map(&:nom)
    options = montee.abandonnabilite.map(&:option).select { |o| noms_options.include? o.nom }
    options.map do |option|
      {
        name: option.nom,
        label: "Poursuivre l'option",
        type: "check",
        condition: !options_abandonnees.include?(option),
        desc: option.nom_et_info
      }
    end
  end

  def options_apres_montee
    options = []
    options += option.map(&:nom).select { |o| o }
    options += demande.map(&:option).map(&:nom)
    (0...options.length).each do |i|
      options[i] += " (-)" if abandon.map(&:option).map(&:nom).include? options[i]
      options[i] += " (+)" if demande.map(&:option).map(&:nom).include? options[i]
    end
    options.uniq.sort
  end

end
