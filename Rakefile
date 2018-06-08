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
  Etablissement
    .where.not(nom: '')
    .each do |etablissement|
    etats, notes, moyenne, commentaires = stats etablissement
    print "#{etablissement.nom} #{etats.join(', ')}\n"
    print "satisfaction #{notes} (moy):#{moyenne}" if notes.count > 0
    print "\n"
    print commentaires.join("\n")
    print "\n"
    print "-------------------------------------\n"
  end
end
