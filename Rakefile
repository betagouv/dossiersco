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

task :traiter_messages do
    traiter_messages
end

task :stats do
  Etablissement
    .where.not(nom: '')
    .each do |etablissement|
    etats, notes, moyenne, dossiers_avec_commentaires = etablissement.stats
    print "#{etablissement.nom} #{etats.join(', ')}\n"
    print "#{notes.count} satisfactions (moy):#{moyenne}" if notes.count > 0
    print "\n"
    print dossiers_avec_commentaires.map {|d| "#{d.date_signature_gmt_plus_2} #{d.satisfaction} #{d.commentaire}"}.join("\n")
    print "\n"
    print "-------------------------------------\n"
  end
end
