require 'test_helper'

class EtablissementTest < ActiveSupport::TestCase

  test "a un fabricant valide" do
    assert Fabricate.build(:etablissement).valid?
  end

  test "invalide si le code postal n'a pas 5 chiffres" do
    assert Fabricate.build(:etablissement, code_postal: 'x').invalid?
  end

  test "avec un code postal, departement renvoie les 2 premiers chiffres du code postal" do
    etablissement = Fabricate.build(:etablissement, code_postal: '77400')

    assert '77', etablissement.departement
  end

  test "sans code postal, departement renvoie une chaine vide" do
    etablissement = Fabricate.build(:etablissement, code_postal: nil)

    assert '', etablissement.departement
  end
end

