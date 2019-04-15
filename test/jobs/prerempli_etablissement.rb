require 'test_helper'

class PrerempliEtablissementTest < ActionDispatch::IntegrationTest

  test "rempli les champs adresse et nom d'un établissement à partir de son UAI" do
    etablissement = Fabricate(:etablissement)
    uai = etablissement.uai

    fakeHTTP = FakeHTTP.new({nom: "Lab110Bis", adresse: "54 rue de bellechasse", code_postal: "75007", commune: "Paris"})
    job = PrerempliEtablissement.new(fakeHTTP)
    job.perform(uai)

    etablissement.reload
    assert_equal "Lab110Bis", etablissement.nom
    assert_equal "54 rue de bellechasse", etablissement.adresse
    assert_equal "75007", etablissement.code_postal
    assert_equal "Paris", etablissement.ville
    assert_equal "https://opencartecomptable.herokuapp.com/api/etablissements?code_uai=#{uai}", fakeHTTP.url
  end

  test "lève une exception si l'établissement n'existe pas" do
    uai = "0754444X"

    fakeHTTP = FakeHTTP.new({})
    job = PrerempliEtablissement.new(fakeHTTP)
    assert_raise StandardError do
      job.perform(uai)
    end
  end

end

class FakeHTTP
  attr_reader :url

  def initialize(valeur_de_retour)
    @valeur_de_retour = valeur_de_retour
  end

  def get(url)
    @url = url
    response = Struct.new(:body)
    response.new([@valeur_de_retour].to_json)
  end
end
