require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

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

get '/tableau_de_bord' do
  agent = Agent.find_by(identifiant: session[:identifiant])
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent}
end
