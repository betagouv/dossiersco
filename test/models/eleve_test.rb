# frozen_string_literal: true

require 'test_helper'

class EleveTest < ActiveSupport::TestCase
  test 'a un fabricant valid' do
    assert Fabricate.build(:eleve).valid?
  end

  test 'affiche option obligatoire nouvelle pour cette montee' do
    etablissement = Fabricate(:etablissement)
    montee = Montee.create
    eleve = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01', montee: montee)
    dossier_eleve = DossierEleve.create!(eleve_id: eleve.id, etablissement_id: etablissement.id)

    grec_obligatoire = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'obligatoire')
    grec_obligatoire_d = Demandabilite.create montee_id: montee.id, option_id: grec_obligatoire.id
    montee.demandabilite << grec_obligatoire_d

    resultat = eleve.genere_demandes_possibles

    assert_equal 'LCA', resultat[0][:label]
    assert_equal 'grec', resultat[0][:name]
    assert_equal 'hidden', resultat[0][:type]
  end

  test 'a une année de naissance' do
    eleve = Fabricate.build(:eleve, date_naiss: '2004-04-27')
    assert_equal '2004', eleve.annee_de_naissance
  end

  test 'a un mois de naissance' do
    eleve = Fabricate.build(:eleve, date_naiss: '2004-04-27')
    assert_equal '04', eleve.mois_de_naissance
  end

  test 'a un jour de naissance' do
    eleve = Fabricate.build(:eleve, date_naiss: '2004-04-27')
    assert_equal '27', eleve.jour_de_naissance
  end

  test "#par_identifiant" do
    eleve = Fabricate(:eleve)
    assert_equal eleve, Eleve.par_identifiant(eleve.identifiant)

    eleve = Fabricate(:eleve, identifiant: "TRUC")
    assert_equal eleve, Eleve.par_identifiant("truc")
  end

end
