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
    message.envoyer

    message = Message.first
    assert_equal 'sms', message.categorie
    assert_equal dossier.id, message.dossier_eleve_id
    assert_equal 'erreur', message.etat
    assert message.contenu.include? 'Tillion'
  end
end
