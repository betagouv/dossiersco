require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'action_mailer'

require './config/initializers/mailjet.rb'
require './config/initializers/actionmailer.rb'
require './config/initializers/carrierwave.rb'

require './helpers/models.rb'
require './uploaders/fichier_uploader.rb'
require './helpers/s3.rb'

configure :staging, :production do
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end

set :database_file, "config/database.yml"

set :session_secret, ENV['SESSION_SECRET']
use Rack::Session::Cookie, :key => 'dossiersco', :path => '/', :secret => ENV['SESSION_SECRET'], :expire_after => 604800

require_relative 'helpers/formulaire'
require_relative 'helpers/init'
require_relative 'helpers/mot_de_passe'



configure :test, :development, :staging do
  get '/init' do
    init
    redirect '/'
  end
end

before '/unepagequileveuneexception' do
  raise ArgumentError
end

before '/*' do
  agent_before = agent
  eleve_before = eleve
  identification = request.path_info == "/identification"
  home = request.path_info == "/"
  piece_jointe = request.path_info.start_with?("/piece")
  agent = request.path_info.start_with?("/agent")
  api = request.path_info.start_with?("/api")
  init = request.path_info.start_with?("/init")
  stats = request.path_info.start_with?("/stats")
  pass if home || identification || piece_jointe || agent || api || init || stats
  pass if eleve_before.present?
  pass if agent_before.present?
  return if home
  session[:message_erreur] = "Vous avez été déconnecté par mesure de sécurité. Merci de vous identifier avant de continuer."
  redirect '/'
end

get '/api/recevoir_sms' do
  puts params.merge(request.content_type == 'application/json' ? JSON.parse(request.body.read) : {})
  status 204
end

post '/api/recevoir_sms' do
  puts params.merge(request.content_type == 'application/json' ? JSON.parse(request.body.read) : {})
  status 204
end

