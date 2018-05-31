require 'sinatra'
require 'sinatra/activerecord/rake'
require 'sinatra/activerecord'

require_relative 'helpers/models'
require_relative 'helpers/agent'
include AgentHelpers

set :database_file, "config/database.yml"

task :traiter_imports do
    traiter_imports
end

task :stats do
    DossierEleve
        .where.not(etat: "pas connecté")
        .group_by(&:etablissement_id)
        .transform_values do |dossiers|
            dossiers.group_by(&:etat)
        end
        .each_pair do |etablissement_id, dossiers_etablissement|
            print "#{Etablissement.find(etablissement_id).nom}:"
            dossiers_etablissement.each do |etat, dossiers_etat|
                print " #{etat}:#{dossiers_etat.count}"
            end
        end
end
