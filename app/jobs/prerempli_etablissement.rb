# frozen_string_literal: true

class PrerempliEtablissement < ActiveJob::Base
  include HTTParty

  def initialize(scrappeur = HTTParty)
    super
    @scrappeur = scrappeur
  end

  def perform(uai)
    etablissement = Etablissement.find_by(uai: uai)
    raise StandardError, 'etablissement_non_trouve' unless etablissement.present?

    response = @scrappeur.get("https://opencartecomptable.herokuapp.com/api/etablissements?code_uai=#{uai}")
    res = JSON.parse(response.body)[0]
    etablissement.update(nom: res['nom'], adresse: res['adresse'], code_postal: res['code_postal'].to_s, ville: res['commune'])
  end
end
