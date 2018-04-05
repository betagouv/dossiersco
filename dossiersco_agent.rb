require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require_relative 'helpers/singulier_francais'
require_relative 'helpers/import_siecle'

set :database_file, "config/database.yml"

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool


get '/agent' do
  erb :'agent/identification'
end

post '/agent' do
  agent = Agent.find_by(identifiant: params[:identifiant])
  mdp_saisi = params[:mot_de_passe]
  mdp_crypte = BCrypt::Password.new(agent.password)
  if mdp_crypte == mdp_saisi
    session[:identifiant] = agent.identifiant
    redirect '/tableau_de_bord'
  else
    session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
    redirect '/agent'
  end
end

get '/liste_des_eleves' do
  agent = Agent.find_by(identifiant: session[:identifiant])
  erb :'agent/liste_des_eleves',
      layout: :layout_agent,
      locals: {agent: agent, dossier_eleves: agent.etablissement.dossier_eleve}
end

get '/tableau_de_bord' do
  agent = Agent.find_by(identifiant: session[:identifiant])
  total_dossiers = agent.etablissement.dossier_eleve.count
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent, total_dossiers: total_dossiers}
end

get '/import_siecle' do
  agent = Agent.find_by(identifiant: session[:identifiant])
  erb :'agent/import_siecle'
end

post '/import_siecle' do
  agent = Agent.find_by(identifiant: session[:identifiant])
  import_xls params[:filename][:tempfile]
  erb :'agent/import_siecle', locals: { message: "L'import a réussit" }
end

post '/change_etat_fichier' do
  dossier_eleve = DossierEleve.find(params[:id])
  dossier_eleve[params[:nom_fichier]] = params[:etat]
  dossier_eleve.save!
end