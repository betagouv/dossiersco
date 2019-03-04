# frozen_string_literal: true

require 'test_helper'

class MessageLegalTest < ActiveSupport::TestCase
  def test_trace_sms_envoyes
    assert_equal 0, Message.count

    eleve = Eleve.find_by(identifiant: '6')
    dossier = eleve.dossier_eleve
    dossier.relance_sms

    assert_equal 1, Message.count
    message = Message.first

    message.envoyer_sms(FakeHttp)

    message = Message.first
    assert_equal 'sms', message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal 'erreur', message.etat
    assert message.contenu.include? 'Tillion'
  end
end

class FakeHttp
  def initialize(host, port)
    @request = Struct.new(:body)
  end

  def use_ssl=(boolean)
  end

  def request(request)
    response = @request.new
    response.body = {messages: [{status: "envoyé"}]}.to_json
    response
  end

  class Post
    def initialize(uri, header)
    end

    def body=(body)
    end
  end
end

