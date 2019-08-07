# frozen_string_literal: true

professions = YAML.load(File.read("lib/professions.yml"))

professions.each do |profession|
  code = profession.keys.first
  libelle = profession.values.first

  RespLegal.where(profession: libelle).update_all(profession: code)
end
