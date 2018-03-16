require 'sinatra'
require 'redis'
require 'redis-load'
require 'json'

require_relative 'helpers/formulaire'

enable :sessions
set :session_secret, "secret"

redis = Redis.new

get '/init' do
	redis.flushall

	loader = RedisLoad::Loader.new(redis)
	loader.load_json("tests/test.json")

	database_content = ""

	redis.keys.each do |key|
		database_content += key + "<br>"
		redis.hgetall(key).each do |field, value|
			database_content += field + " : " + value + "<br>"
		end
		database_content += "<br>"
	end

	database_content

end

get '/' do
	erb :'#_identification', layout: false
end

post '/identification' do
	if params[:identifiant].empty? || params[:date_naiss].empty?
		session[:erreur_id_ou_date_naiss_absente] = true
		redirect '/'
	end

	identifiant = params[:identifiant]
	date_naiss_fournie = params[:date_naiss]
	date_naiss_secrete = get_date_naiss_eleve(redis, identifiant)

	if date_naiss_secrete == date_naiss_fournie
		session[:identifiant] = identifiant
		session[:demarche] = get_demarche(redis, session[:identifiant])
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
	erb :'0_accueil', locals: { redis: redis }
end

get '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = get_eleve(redis, identifiant)
	erb :'1_eleve', locals: eleve
end

post '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = get_eleve(redis, identifiant)
	identite_eleve = ['prenom', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
  identite_eleve.each do |info|
		eleve[info] = params[info] if params.has_key?(info)
  end

	redis.hmset "dossier_eleve:#{identifiant}", :eleve, eleve.to_json
	redirect to('/scolarite')
end

get '/scolarite' do
	identifiant = session[:identifiant]
	eleve = get_eleve(redis, identifiant)
	eleve['lv2'] = eleve['lv2'] or ''
	erb :'2_scolarite', locals: eleve
end

post '/scolarite' do
	identifiant = session[:identifiant]
	eleve = get_eleve(redis, identifiant)
	enseignements_eleve = ['lv2']
	enseignements_eleve.each do |enseignement|
		eleve[enseignement] = params[enseignement] if params.has_key?(enseignement)
  end
	redis.hmset "dossier_eleve:#{identifiant}", :eleve, eleve.to_json
  redirect to('/famille')
end

get '/famille' do
	erb :'3_famille'
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
