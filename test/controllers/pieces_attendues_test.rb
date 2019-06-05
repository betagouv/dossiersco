# frozen_string_literal: true

require "test_helper"

class PiecesAttenduesTest < ActionDispatch::IntegrationTest

  test "crée une piece attendue" do
    admin = Fabricate(:admin)
    identification_agent(admin)

    params = { piece_attendue: { nom: "livret", explication: "parce que", obligatoire: false } }
    post configuration_pieces_attendues_path, params: params

    assert_redirected_to configuration_campagnes_path
    assert_equal "livret", PieceAttendue.last.nom
    assert_equal "parce que", PieceAttendue.last.explication
    assert_equal false, PieceAttendue.last.obligatoire
  end

end
