require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require_relative 'helpers/singulier_francais'
require_relative 'helpers/import_siecle'
require_relative 'helpers/agent'

set :database_file, "config/database.yml"

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool

before '/agent/*' do
  redirect '/agent' unless agent.present?
end

get '/agent' do
  erb :'agent/identification'
end

post '/agent' do
  agent = Agent.find_by(identifiant: params[:identifiant])
  mdp_saisi = params[:mot_de_passe]
  mdp_crypte = BCrypt::Password.new(agent.password)
  if mdp_crypte == mdp_saisi
    session[:identifiant] = agent.identifiant
    redirect '/agent/tableau_de_bord'
  else
    session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
    redirect '/agent'
  end
end

get '/agent/liste_des_eleves' do
  erb :'agent/liste_des_eleves',
      layout: :layout_agent,
      locals: {agent: agent, dossier_eleves: agent.etablissement.dossier_eleve}
end

get '/agent/tableau_de_bord' do
  total_dossiers = agent.etablissement.dossier_eleve.count
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent, total_dossiers: total_dossiers}
end

get '/agent/import_siecle' do
  erb :'agent/import_siecle'
end

post '/agent/import_siecle' do
  statistiques = import_xls params[:filename][:tempfile], agent.etablissement.id, params[:nom_eleve], params[:prenom_eleve]
  erb :'agent/import_siecle',
      locals: { message: "#{statistiques[:eleves]} élèves importés : "+
          "#{statistiques[:portable]}% de téléphones portables et "+
          "#{statistiques[:email]}% d'emails"
      }
end

get '/agent/eleve/:identifiant' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  erb :'agent/eleve', locals: { eleve: eleve }
end

post '/agent/change_etat_fichier' do
    dossier_eleve = DossierEleve.find(params[:id])
    dossier_eleve[params[:nom_fichier]] = params[:etat]
    dossier_eleve.save!
end