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

    rl = resp_legal_1
    numero = rl.tel_secondaire || rl.tel_principal

    # Avec Nexmo
    if numero
      numero_prefixe = numero.gsub(/[[:space:]]/,'').gsub(/^0/,'+33')
      uri = URI.parse("https://rest.nexmo.com/sms/json")

      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      header = {'Content-Type': 'application/json'}
      payload = {
        'api_key':"#{ENV['NEXMO_KEY']}",
        'api_secret':"#{ENV['NEXMO_SECRET']}",
        'from': ENV['NEXMO_SENDER'], 'to': numero_prefixe, 'text':text}

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = payload.to_json

      response = https.request(request)
    end
  end

end
