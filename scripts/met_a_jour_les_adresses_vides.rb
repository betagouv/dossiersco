# frozen_string_literal: true

RespLegal.select { |d| d.adresse&.strip == "" }.each do |d|
  d.update(adresse: "Inconnue")
end
