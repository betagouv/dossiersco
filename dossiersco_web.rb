require 'sinatra'
require 'redis'

get '/' do
	erb :identification
end

# depuis page identification
post '/accueil' do
	erb :'0_accueil/accueil'
end

# depuis logo dossiersco
get '/accueil' do
	erb :'0_accueil/accueil'
end


post '/eleve' do
	erb :'1_eleve/eleve'
end
get '/eleve' do
	erb :'1_eleve/eleve'
end


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
	erb :confirmation
end
post '/confirmation' do
	erb :confirmation
end

##################################################

redis = Redis.new

get '/tableau_de_bord' do
	eleve_keys = redis.keys("ELEVE:*")
	@liste_eleves = []
	eleve_keys.each do |eleve_key|
		@liste_eleves << redis.hgetall(eleve_key)
	end	
 	erb :tableau_de_bord
end