# frozen_string_literal: true

require "uri"
require "net/http"
require "net/https"
require "json"
require "tilt/erb"

class DossierEleve < ActiveRecord::Base

  belongs_to :eleve
  belongs_to :etablissement
  belongs_to :mef_origine, class_name: "Mef", required: false
  belongs_to :mef_destination, class_name: "Mef", required: false
  belongs_to :regime_sortie, required: false

  has_many :resp_legal, dependent: :destroy
  has_many :piece_jointe, dependent: :destroy
  has_many :message, dependent: :destroy

  has_one :contact_urgence, dependent: :destroy

  has_and_belongs_to_many :options_pedagogiques

  ETAT = {
    pas_connecte: "pas connecté",
    connecte: "connecté",
    en_attente: "en attente",
    en_attente_de_validation: "en attente de validation",
    valide: "validé",
    sortant: "sortant"
  }.freeze

  # TODO: utiliser cette liste pour les différents étape d'avancement ?
  DERNIERE_ETAPE = {
    accueil: "accueil",
    eleve: "eleve",
    famille: "famille",
    administration: "administration",
    confirmation: "confirmation",
    pieces_a_joindre: "pieces_a_joindre"
  }.freeze

  validates :etat, inclusion: { in: ETAT.values }

  # TODO: fusionner Eleve et DossierEleve
  default_scope { joins(:eleve) }

  scope :pour, lambda { |etablissement|
    where(etablissement: etablissement)
  }

  scope :a_convoquer, lambda {
    where("etat in (?)", [ETAT[:pas_connecte], ETAT[:connecte]])
  }

  def self.par_authentification(identifiant, jour, mois, annee)
    eleve = Eleve.par_authentification(identifiant, jour, mois, annee)
    return eleve.dossier_eleve if eleve.is_a?(Eleve)

    nil
  end

  def pieces_jointes
    etablissement.pieces_attendues.map do |piece_attendue|
      PieceJointe.find_or_initialize_by(piece_attendue: piece_attendue, dossier_eleve: self)
    end
  end

  def resp_legal_1
    resp_legal.find { |r| r.priorite == 1 }
  end

  def resp_legal_2
    resp_legal.find { |r| r.priorite == 2 }
  end

  def email_resp_legal_1
    resp_legal_1&.email
  end

  def email; end

  def allocataire
    enfants = resp_legal.first.enfants_a_charge || 0
    enfants > 1
  end

  DEFAULT_TEMPLATE = "<%= eleve.dossier_eleve.etablissement.nom %>: attention,"\
    " derniers jours pour réinscrire votre enfant <%= eleve.prenom %> "\
    " sur https://dossiersco.fr avec vos identifiants: <%= eleve.identifiant %>"\
    " et la date de naissance de l'enfant."

  def relance_sms(template = DEFAULT_TEMPLATE)
    # Construction du message
    template = Tilt["erb"].new { template }
    text = template.render(nil, eleve: eleve)

    Message.create(categorie: "sms", contenu: text, etat: ETAT[:en_attente], dossier_eleve: self)
  end

  def portable_present
    portable_rl1.present? || portable_rl2.present?
  end

  def portable_rl1
    portable resp_legal_1
  end

  def portable_rl2
    portable resp_legal_2 if resp_legal_2
  end

  def portable(responsable_legal)
    secondaire = responsable_legal.tel_portable
    return secondaire unless secondaire.blank? || secondaire.start_with?("01")

    responsable_legal.tel_personnel
  end

  def date_signature_gmt_plus_2
    return "" unless date_signature

    date_signature.localtime("+02:00").strftime "%d/%m à %H:%M"
  end

  def pieces_manquantes
    result = []
    PieceAttendue.where(etablissement: etablissement, obligatoire: true).each do |piece_attendue|
      result << piece_attendue unless piece_jointe.where(piece_attendue: piece_attendue).any?
    end
    result
  end

  def pieces_manquantes?
    pieces_manquantes.any?
  end

  def valide!
    update(etat: ETAT[:valide])
  end

  def deja_connecte?
    etat != ETAT[:pas_connecte]
  end

  def moyens_de_communication_electronique
    moyens = {}
    resp_legal.each do |representant|
      moyens[representant.nom_complet] = representant.moyens_de_communication.select do |moyen|
        moyen.delete(" ")[0..1] != "+3" &&
          moyen.delete(" ")[0..1] != "01" &&
          moyen.delete(" ")[0..1] != "02" &&
          moyen.delete(" ")[0..1] != "03" &&
          moyen.delete(" ")[0..1] != "04" &&
          moyen.delete(" ")[0..1] != "05" &&
          moyen.delete(" ")[0..1] != "09"
      end
    end
    moyens
  end

end
