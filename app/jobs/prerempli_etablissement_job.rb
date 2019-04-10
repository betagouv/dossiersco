class PrerempliEtablissementJob < ActiveJob::Base
  include HTTParty

  def perform(uai)
    etablissement = Etablissement.find_by(uai: uai)
    response = HTTParty.get("https://opencartecomptable.herokuapp.com/api/etablissements?code_uai=#{uai}")
    res = JSON.parse(response.body)[0]
    etablissement.update(nom: res["nom"], adresse: res["adresse"], code_postal: res["code_postal"].to_s, ville: res["commune"])
  end
end