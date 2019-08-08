# frozen_string_literal: true

professions = YAML.safe_load(File.read("lib/professions.yml"))

professions.each do |profession|
  code = profession.keys.first
  libelle = profession.values.first

  RespLegal.where(profession: libelle).update_all(profession: code)
end

RespLegal.where(profession: "Retraité cadre, profession interm édiaire").update_all(profession: "74")
RespLegal.where(profession: "Retraité employé, ouvrier").update_all(profession: "77")
RespLegal.where(profession: "Person without professional activity> 60 years").update_all(profession: "86")
