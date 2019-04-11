# frozen_string_literal: true

require 'test_helper'

class EleveTest < ActiveSupport::TestCase
  test 'a un fabricant valid' do
    assert Fabricate.build(:eleve).valid?
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
