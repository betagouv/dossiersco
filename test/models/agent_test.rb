# frozen_string_literal: true

require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  def test_a_un_fabricant_valide
    assert Fabricate.build(:agent).valid?
    assert Fabricate.build(:admin).valid?
  end

  test "l'identifiant d'un agent est unique" do
    Fabricate(:agent, identifiant: 'Henri')
    assert Fabricate.build(:agent, identifiant: 'Henri').invalid?
  end

  test "l'identifiant d'un agent est unique peu importe la casse" do
    Fabricate(:agent, identifiant: 'henri')
    assert Fabricate.build(:agent, identifiant: 'Henri').invalid?
  end

  test "renvoie le nom complet de l'agent" do
    agent = Fabricate(:agent, nom: 'Astier', prenom: 'Alexandre')
    assert_equal "Alexandre Astier", agent.nom_complet
  end

  test "renvoie le prenom pour le nom complet si pas de nom" do
    agent = Fabricate(:agent, prenom: 'Alexandre', nom: nil)
    assert_equal "Alexandre", agent.nom_complet
  end

  test "renvoie le nom pour le nom complet si pas de prenom" do
    agent = Fabricate(:agent, nom: 'Astier', prenom: nil)
    assert_equal "Astier", agent.nom_complet
  end

  test "renvoie l'email pour le nom complet si pas de prenom ni nom" do
    agent = Fabricate(:agent, nom: nil, prenom: nil, email: "alexandre@astier.com")
    assert_equal "alexandre@astier.com", agent.nom_complet
  end

  test 'mot de passe obligatoire si pas de jeton' do
    assert Fabricate.build(:agent, password: nil, jeton: nil).invalid?
    assert Fabricate.build(:agent, password: 'a-password', jeton: nil).valid?
  end

  test 'jeton obligatoire si pas de mot de passe' do
    assert Fabricate.build(:agent, password: nil, password_confirmation: nil, jeton: nil).invalid?
    assert Fabricate.build(:agent, password: nil, password_confirmation: nil, jeton: 'a-sha1-token').valid?
  end
end
