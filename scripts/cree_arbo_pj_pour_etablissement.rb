# frozen_string_literal: true

require "yaml"
require "fileutils"

pj = YAML.safe_load(File.read(ARGV[0]))
pj.each do |dossier|
  path = "#{dossier['nom']}_#{dossier['prenom']}_#{dossier['ine']}"
  FileUtils.mkdir_p(path)
  FileUtils.cp(dossier["fichiers"], path) if dossier["fichiers"]
end
