# frozen_string_literal: true

RespLegal.select { |d| d.enfants_a_charge.nil? && d.adresse&.strip == "" }.each do |d|
  d.update(enfants_a_charge: 1, adresse: "Inconnue")
end
