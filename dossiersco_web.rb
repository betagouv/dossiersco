require 'sinatra'
require 'redis'
require 'json'


redis = Redis.new


get '/init' do
	eleve =
		{
			prenom_elv: "Etienne",
			nom_elv: "Puydebois",
			sexe_elv: "",
			date_naiss_elv: "1995-11-19",
			ville_naiss_elv: "",
			pays_naiss_elv: "",
			nationalite_elv: "",
			classe_ant_elv: "",
			ets_ant_elv: "Ecole René Cassin (Aubazine)"
		}
	redis.set "eleve", eleve.to_json	
end


get '/' do
	erb :identification, layout: false
end


post '/accueil' do
	erb :'0_accueil/accueil'
end
get '/accueil' do
	erb :'0_accueil/accueil'
end


post '/eleve' do
	eleve = JSON.parse(redis.get("eleve"))
	erb :'1_eleve/eleve', locals: eleve
end
get '/eleve' do
	eleve = JSON.parse(redis.get("eleve"))
	erb :'1_eleve/eleve', locals: eleve
end


post '/resp_legal_1' do
	eleve_modifie =
		{	
			prenom_elv: "Etienne",
			nom_elv: "Puydebois",
			sexe_elv: params[:sexe_elv],
			date_naiss_elv: "1995-11-19",
			ville_naiss_elv: params[:ville_naiss_elv],
			pays_naiss_elv: params[:pays_naiss_elv],
			nationalite_elv: params[:nationalite_elv],
			classe_ant_elv: params[:classe_ant_elv],
			ets_ant_elv: "Ecole René Cassin (Aubazine)"
		}
	redis.set "eleve", eleve_modifie.to_json
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