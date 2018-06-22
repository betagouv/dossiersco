require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'tilt/erb'

class DossierEleve < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :etablissement
  has_many :resp_legal
  has_one :contact_urgence
  has_many :piece_jointe
  has_many :message

  def resp_legal_1
    self.resp_legal.find {|r| r.priorite == 1}
  end

  def resp_legal_2
    self.resp_legal.find {|r| r.priorite == 2}
  end

  def allocataire
    enfants = self.resp_legal.first.enfants_a_charge || 0
    enfants > 1
  end

  def relance_sms
    # Construction du message
    template = "<%= eleve.dossier_eleve.etablissement.nom %>: attention, derniers jours pour réinscrire votre enfant <%= eleve.prenom %> sur https://dossiersco.fr avec vos identifiants: <%= eleve.identifiant %> et la date de naissance de l'enfant."
    template = Tilt['erb'].new { template }
    text = template.render(nil,eleve: eleve)

    Message.create(categorie:"sms", contenu: text, etat: "en attente", dossier_eleve: self)
  end

  def portable_rl1
    rl = resp_legal_1
    rl.tel_secondaire || rl.tel_principal
  end

end
