# frozen_string_literal: true

class SupprimeRespLegal2Fantomes < ActiveRecord::Migration[5.2]
  def change
    RespLegal
      .select { |r| !r.nom.present? && !r.prenom.present? && !r.lien_de_parente.present? }
      .map(&:destroy!)
  end
end
