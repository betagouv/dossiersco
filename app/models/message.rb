# frozen_string_literal: true

class Message < ActiveRecord::Base

  belongs_to :dossier_eleve

  def numero
    destinataire == "rl2" ? dossier_eleve.portable_rl2 : dossier_eleve.portable_rl1
  end

  def envoyer_sms(http = Net::HTTP)
    if numero
      numero_prefixe = numero.gsub(/[[:space:]]/, "").gsub(/^0/, "+33")
      uri = URI.parse("https://rest.nexmo.com/sms/json")

      https = http.new(uri.host, uri.port)
      https.use_ssl = true

      header = { 'Content-Type': "application/json" }
      payload = {
        'api_key': (ENV["NEXMO_KEY"]).to_s,
        'api_secret': (ENV["NEXMO_SECRET"]).to_s,
        'from': ENV["NEXMO_SENDER"], 'to': numero_prefixe, 'text': contenu
      }

      request = http::Post.new(uri.request_uri, header)
      request.body = payload.to_json

      response = https.request(request)

      resultat = JSON.parse(response.body)
      etat = resultat["messages"].any? { |m| m["status"].to_s != "0" } ? "erreur" : "envoyé"
      update(resultat: response.body, etat: etat)

      sleep(2) unless ENV["rack_env"] == "test"
    else
      update(resultat: "Pas de numéro", etat: "abandon")
    end
  end

end
