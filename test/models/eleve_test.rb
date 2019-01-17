require 'test_helper'

class EleveTest < ActiveSupport::TestCase

  def test_a_un_fabricant_valid
    assert Fabricate.build(:eleve).valid?

  end

  def test_affiche_option_obligatoire_nouvelle_pour_cette_montee
    montee = Montee.create
    eleve = Eleve.create!(identifiant: 'XXX', date_naiss: '1970-01-01', montee: montee)
    dossier_eleve = DossierEleve.create!(eleve_id: eleve.id, etablissement_id: Etablissement.first.id)

    grec_obligatoire = Option.create(nom: 'grec', groupe: 'LCA', modalite: 'obligatoire')
    grec_obligatoire_d = Demandabilite.create montee_id: montee.id, option_id: grec_obligatoire.id
    montee.demandabilite << grec_obligatoire_d

    resultat = eleve.genere_demandes_possibles

    assert_equal "LCA", resultat[0][:label]
    assert_equal 'grec', resultat[0][:name]
    assert_equal 'hidden', resultat[0][:type]
  end

end
