require 'sinatra'
require 'redis'
require 'json'

require_relative 'helpers/formulaire'

enable :sessions

redis = Redis.new

# sessions sinatra

get '/init' do
	eleve_1 =
		{
            prenom: "Etienne",
            nom: "Léonard",
            sexe: "",
            date_naiss: "1995-11-19",
            ville_naiss: "",
            pays_naiss: "",
            nationalite: "",
            classe_ant: "",
            ets_ant: "Ecole Picpus A (Paris 12e)"
        }
    redis.set "eleve:1", eleve_1.to_json    
end


get '/' do
    locals = {erreur_de_connexion: session[:erreur_de_connexion]}
	erb :identification, locals: locals, layout: false
end


post '/accueil' do
    if params[:identifiant] == "1" || params[:identifiant] == "1225804331"
	   erb :'0_accueil/accueil'
    else
        session[:erreur_de_connexion] = true
        redirect '/'
    end
end
get '/accueil' do
	erb :'0_accueil/accueil'
end

# je suis sur la page élève
# je remplis les champs
# je clique sur enregistrer et continuer
# il y a un post sur eleve
# dans lequel je fais redis.set eleve_modifie
# puis redirect sur get RL1
# j'arrive dans get RL1
# je vais chercher les infos qui concernet le RL1
# json.parse redis RL1
# j'affiche l'erb RL1


get '/eleve' do
	eleve = JSON.parse(redis.get("eleve:1"))
	erb :'1_eleve/eleve', locals: eleve
end

post '/eleve' do
	eleve_modifie =
		{
			prenom: params[:prenom],
			nom: params[:nom],
			sexe: params[:sexe],
			date_naiss: "1995-11-19",
			ville_naiss: params[:ville_naiss],
			pays_naiss: params[:pays_naiss],
			nationalite: params[:nationalite],
			classe_ant: params[:classe_ant],
			ets_ant: params[:ets_ant]
		}
	redis.set "eleve:1", eleve_modifie.to_json
	redirect to('/resp_legal_1') 
end

# plus besoin de parse dans le post
# get va chercher la ressource
# post modifie la ressource et redirect vers étape suivante
# dans le controleur bidule il n'y a que bidule
# redirect utilisé partout

post '/resp_legal_1' do

	erb :'2_famille/2_1_resp_legal_1'
end
get '/resp_legal_1' do
	erb :'2_famille/2_1_resp_legal_1'
end


post '/resp_legal_2' do
	erb :'2_famille/2_2_resp_legal_2'
end
get '/resp_legal_2' do
	erb :'2_famille/2_2_resp_legal_2'
end


post '/urgence' do
	erb :'2_famille/2_3_urgence'
end
get '/urgence' do
	erb :'2_famille/2_3_urgence'
end


post '/choix_pedagogiques' do
	erb :'3_choix_pedagogiques/choix_pedagogiques'
end
get '/choix_pedagogiques' do
	erb :'3_choix_pedagogiques/choix_pedagogiques'
end


post '/regime' do
	erb :'4_administration/4_1_regime'
end
get '/regime' do
	erb :'4_administration/4_1_regime'
end


post '/autorisation_sortie' do
	erb :'4_administration/4_2_autorisation_sortie'
end
get '/autorisation_sortie' do
	erb :'4_administration/4_2_autorisation_sortie'
end


post '/medical' do
	erb :'4_administration/4_3_medical'
end
get '/medical' do
	erb :'4_administration/4_3_medical'
end


post '/droit_image' do
	erb :'4_administration/4_4_droit_image'
end
get '/droit_image' do
	erb :'4_administration/4_4_droit_image'
end


post '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre/pieces_a_joindre'
end
get '/pieces_a_joindre' do
	erb :'5_pieces_a_joindre/pieces_a_joindre'
end


post '/validation' do
	erb :'6_validation/validation'
end
get '/validation' do
	erb :'6_validation/validation'
end


get '/confirmation' do
	erb :'7_confirmation/confirmation'
end
post '/confirmation' do
	erb :'7_confirmation/confirmation'
end


get '/tableau_de_bord' do
	eleve_keys = redis.keys("ELEVE:*")
	@liste_eleves = []
	eleve_keys.each do |eleve_key|
		@liste_eleves << redis.hgetall(eleve_key)
	end	
 	erb :tableau_de_bord
end