# frozen_string_literal: true

require "nexmo"

class FamilleTextoer

  def initialize
    @client = Nexmo::Client.new(
      api_key: ENV["SMS_API_KEY"],
      api_secret: ENV["SMS_API_SECRET"]
    )
  end

  def envoyer_message(tel, message)
    @client.sms.send(
      from: "DossierSCO",
      to: tel,
      text: message
    )
  end

end
