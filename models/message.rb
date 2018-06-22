class Message < ActiveRecord::Base
  belongs_to :dossier_eleve

  def envoyer
    case self.categorie
    when "sms"
      envoyer_sms
    end
  end

  def envoyer_sms
    numero = dossier_eleve.portable_rl1
    if numero
      numero_prefixe = numero.gsub(/[[:space:]]/,'').gsub(/^0/,'+33')
      uri = URI.parse("https://rest.nexmo.com/sms/json")

      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      header = {'Content-Type': 'application/json'}
      payload = {
        'api_key':"#{ENV['NEXMO_KEY']}",
        'api_secret':"#{ENV['NEXMO_SECRET']}",
        'from': ENV['NEXMO_SENDER'], 'to': numero_prefixe, 'text': contenu}

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = payload.to_json

      response = https.request(request)

      resultat = JSON.parse(response.body)
      etat = resultat["messages"].any? {|m| m["status"] != 0} ? "erreur" : "envoyé"
      Message.update(resultat: resultat, etat:etat)

      sleep(2) unless ENV['rack_env'] == "test"
    else
      Message.update(resultat: "Pas de numéro", etat:"abandon")
    end
  end
end
