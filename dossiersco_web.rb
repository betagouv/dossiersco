require 'sinatra'
require 'json'
require 'sinatra/activerecord'

require './models/eleve.rb'
require './models/dossier_eleve.rb'
require './models/resp_legal.rb'
require './models/contact_urgence.rb'
require './models/etablissement.rb'

set :database_file, "config/database.yml"

require_relative 'helpers/formulaire'
require_relative 'helpers/init'

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool

get '/init' do
  init
end

get '/' do
	erb :'#_identification', layout: false
end

post '/identification' do
	if params[:identifiant].empty? || params[:date_naiss].empty?
		session[:erreur_id_ou_date_naiss_absente] = true
		redirect '/'
	end
	dossier_eleve = get_dossier_eleve params[:identifiant]
	eleve = dossier_eleve.eleve
	if eleve.date_naiss == params[:date_naiss]
		session[:identifiant] = params[:identifiant]
		session[:demarche] = dossier_eleve.demarche
		redirect "/#{session[:identifiant]}/accueil"
	else
		session[:erreur_id_ou_date_naiss_incorrecte] = true
		redirect '/'
	end
end

get '/:identifiant/accueil' do
	if params[:identifiant] != session[:identifiant]
		redirect "/"
  end
  dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'0_accueil', locals: { dossier_eleve: dossier_eleve }
end

get '/eleve/:identifiant' do
  eleve = get_eleve session[:identifiant]
  erb :'1_eleve', locals: { eleve: eleve }
end

# pertinant de garder l'identifiant dans l'url ?
post '/eleve/:identifiant' do
  eleve = get_eleve session[:identifiant]
	identite_eleve = ['prenom', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
	identite_eleve.each do |info|
		eleve[info] = params[info] if params.has_key?(info)
  end

  if eleve.save!
	  redirect '/scolarite'
  else
    redirect "/eleve/#{session[:identifiant]}"
  end
end

get '/scolarite' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'2_scolarite', locals: {eleve: dossier_eleve.eleve}
end

post '/scolarite' do
	eleve = get_eleve session[:identifiant]
	enseignements_eleve = ['lv2']
	enseignements_eleve.each do |enseignement|
		eleve[enseignement] = params[enseignement] if params.has_key?(enseignement)
  end
  if eleve.save!
    redirect '/famille'
  else
    redirect '/scolarite'
  end
end

get '/famille' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'3_famille'
end

post '/famille' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	p "----------------- params : #{params}"
	redirect '/famille'
end

get '/administration' do
	erb :'4_administration'
end

get '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre'
end

get '/validation' do
	erb :'6_validation'
end

get '/confirmation' do
	erb :'7_confirmation'
end

get '/agent' do
	erb :'agent', layout: :layout_agent
end

# REINSCRIPTIONS

get '/r0' do
	erb :'r0_accueil'
end

get '/r1' do
	erb :'r1_scolarite'
end

get '/r2' do
	erb :'r2_famille'
end

get '/r3' do
	erb :'4_administration'
end

get '/r4' do
	erb :'5_pieces_a_joindre'
end

get '/r5' do
	erb :'6_validation'
end

get '/r6' do
	erb :'7_confirmation'
end
