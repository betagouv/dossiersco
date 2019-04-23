# frozen_string_literal: true

require 'test_helper'

class PiecesAttenduesTest < ActionDispatch::IntegrationTest
  test "affiche le formulaire de création d'une piece attentude" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    get configuration_pieces_attendues_path

    assert_response :success
  end

  test 'crée une piece attendue' do
    admin = Fabricate(:admin)
    identification_agent(admin)

    post configuration_pieces_attendues_path, params: { piece_attendue: { nom: 'livret', explication: 'parce que', obligatoire: false } }

    assert_redirected_to configuration_pieces_attendues_path
    assert_equal 'livret', PieceAttendue.last.nom
    assert_equal 'parce que', PieceAttendue.last.explication
    assert_equal false, PieceAttendue.last.obligatoire
  end
end
