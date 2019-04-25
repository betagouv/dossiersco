# frozen_string_literal: true

require "test_helper"

class MessageLegalTest < ActiveSupport::TestCase

  test "appel l'api d'envoie de SMS" do
    resp = Fabricate(:resp_legal, tel_portable: "1234567890")
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp])
    message = Fabricate(:message, dossier_eleve: dossier, categorie: "sms")
    message.envoyer_sms(FakeHttp)

    message = Message.first
    assert_equal "sms", message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal "erreur", message.etat
  end

end

class FakeHttp

  def initialize(_host, _port)
    @request = Struct.new(:body)
  end

  def use_ssl=(boolean); end

  def request(_request)
    response = @request.new
    response.body = { messages: [{ status: "envoyé" }] }.to_json
    response
  end

  class Post

    def initialize(uri, header); end

    def body=(body); end

  end

end
