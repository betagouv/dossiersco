require 'sinatra'
require 'redis'
require 'json'

require_relative 'helpers/formulaire'

enable :sessions

redis = Redis.new

get '/init' do

	eleve =
		{
			prenom: "Etienne",
			nom: "Puydebois",
			sexe: "",
			date_naiss: "1995-11-19",
			ville_naiss: "",
			pays_naiss: "",
			nationalite: "",
			classe_ant: "",
			ets_ant: "Ecole Picpus A (Paris 12e)"
		}
	resp_legal_1 =
		{
			prenom: "Catherine",
			nom: "Puydebois"
		}
	redis.hmset "dossier_eleve:1", :eleve, eleve.to_json, :resp_legal_1, resp_legal_1.to_json

	eleve =
		{
			prenom: "Edith",
			nom: "Piaf",
			sexe: "",
			date_naiss: "1915-12-19",
			ville_naiss: "",
			pays_naiss: "",
			nationalite: "",
			classe_ant: "",
			ets_ant: "Ecole Picasso (Nîmes)"
		}
	resp_legal_1 =
		{
			prenom: "Jean",
			nom: "Piaf"
		}
	redis.hmset "dossier_eleve:2", :eleve, eleve.to_json, :resp_legal_1, resp_legal_1.to_json

	database_content = ""

	redis.keys.reverse_each do |hash|
		database_content += hash + "<br>"
		redis.hgetall(hash).reverse_each do |key, value|
			database_content += key + " : " + value + "<br>"
		end
		database_content += "<br>"
	end

	database_content

end


get '/' do
	erb :'#_identification', layout: false
end


post '/accueil' do
	identifiant = params[:identifiant]
	date_naiss = params[:date_naiss]

	if identifiant == "0"
		session[:identifiant] = identifiant
		erb :'r0_accueil'

	elsif identifiant == "1" && date_naiss == "1995-11-19"
		session[:identifiant] = identifiant
		eleve = JSON.parse(redis.hget("dossier_eleve:#{identifiant}",:eleve))
		erb :'0_accueil', locals: eleve

	elsif identifiant == "2" && date_naiss == "1990-10-10"
		session[:identifiant] = identifiant
		eleve = JSON.parse(redis.hget("dossier_eleve:#{identifiant}",:eleve))
		erb :'0_accueil', locals: eleve

	elsif identifiant == "3"
		session[:identifiant] = "1"
		eleve = JSON.parse(redis.hget("dossier_eleve:1",:eleve))
		erb :'0_accueil', locals: eleve

	else
		session[:erreur_de_connexion] = true
		redirect '/'
	end

end

get '/accueil' do
	erb :'0_accueil'
end


get '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = JSON.parse(redis.hget("dossier_eleve:#{identifiant}",:eleve))
	erb :'1_eleve', locals: eleve
end

post '/eleve/:identifiant' do
	identifiant = params[:identifiant]
	eleve = JSON.parse(redis.hget("dossier_eleve:#{identifiant}",:eleve))
	eleve_modifie =
		{
			prenom: eleve["prenom"],
			nom: params[:nom],
			sexe: params[:sexe],
			date_naiss: "1995-11-19",
			ville_naiss: params[:ville_naiss],
			pays_naiss: params[:pays_naiss],
			nationalite: params[:nationalite],
			classe_ant: params[:classe_ant],
			ets_ant: params[:ets_ant]
		}
	redis.hmset "dossier_eleve:#{identifiant}", :eleve, eleve_modifie.to_json
	redirect to('/resp_legal_1')
end


get '/resp_legal_1' do
	resp_legal_1 = JSON.parse(redis.hget("dossier_eleve:1",:resp_legal_1))
	erb :'2_famille', locals: resp_legal_1
end
post '/resp_legal_1' do
	resp_legal_1_modifie =
		{
			prenom: params[:prenom],
			nom: params[:nom]
		}
    redis.hmset "dossier_eleve:1225804331", :resp_legal_1, resp_legal_1_modifie.to_json
	redirect to('/resp_legal_2')
end


post '/resp_legal_2' do
	erb :'2_famille'
end
get '/resp_legal_2' do
	erb :'2_famille'
end


post '/urgence' do
	erb :'2_famille'
end
get '/urgence' do
	erb :'2_famille'
end


post '/choix_pedagogiques' do
	erb :'3_scolarite'
end
get '/choix_pedagogiques' do
	erb :'3_scolarite'
end


post '/regime' do
	erb :'4_administration'
end
get '/regime' do
	erb :'4_administration'
end


post '/autorisation_sortie' do
	erb :'4_administration'
end
get '/autorisation_sortie' do
	erb :'4_administration'
end


post '/medical' do
	erb :'4_administration'
end
get '/medical' do
	erb :'4_administration'
end


post '/droit_image' do
	erb :'4_administration'
end
get '/droit_image' do
	erb :'4_administration'
end


post '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre'
end
get '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre'
end


post '/validation' do
	erb :'6_validation'
end
get '/validation' do
	erb :'6_validation'
end


get '/confirmation' do
	erb :'7_confirmation'
end
post '/confirmation' do
	erb :'7_confirmation'
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
	erb :'r3_administration'
end

get '/r4' do
	erb :'r4_pieces_a_joindre'
end

get '/r5' do
	erb :'r5_validation'
end

get '/r6' do
	erb :'r6_confirmation'
end