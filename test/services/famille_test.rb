# frozen_string_literal: true

require "test_helper"

class FamilleTest < ActiveSupport::TestCase

  test "#retouve_un_email lève une exception si aucun email trouvé" do
    resp1 = Fabricate(:resp_legal, email: nil, priorite: 1)
    resp2 = Fabricate(:resp_legal, email: nil, priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_raise ExceptionAucunEmailRetrouve do
      Famille.new.retrouve_un_email(dossier)
    end
  end

  test "#retouve_un_email retourne le mail du resp1 quand renseigné" do
    resp1 = Fabricate(:resp_legal, email: "henri@ford.com", priorite: 1)
    resp2 = Fabricate(:resp_legal, email: nil, priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "henri@ford.com", Famille.new.retrouve_un_email(dossier)
  end

  test "#retouve_un_email retourne le mail du resp2 quand email resp1 non renseigné" do
    resp1 = Fabricate(:resp_legal, email: nil, priorite: 1)
    resp2 = Fabricate(:resp_legal, email: "malcom@x.com", priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "malcom@x.com", Famille.new.retrouve_un_email(dossier)
  end

  test "#retouve_un_email retourne le mail du resp1 quand les deux représentant ont un email" do
    resp1 = Fabricate(:resp_legal, email: "henri@ford.com", priorite: 1)
    resp2 = Fabricate(:resp_legal, email: "malcom@x.com", priorite: 2)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp1, resp2])
    assert_equal "henri@ford.com", Famille.new.retrouve_un_email(dossier)
  end

end
