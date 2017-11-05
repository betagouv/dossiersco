require 'sinatra'
require 'redis'

redis = Redis.new

get '/tableau_de_bord' do
	eleve_keys = redis.keys("ELEVE:*")
	@liste_eleves = []
	eleve_keys.each do |eleve_key|
		@liste_eleves << redis.hgetall(eleve_key)
	end	
 	erb :tableau_de_bord
end

get '/' do
	erb :identification
end

get '/accueil' do
	erb :accueil
end

post '/accueil' do
	erb :accueil
end

post '/eleve_identite' do
	fiche_eleve = {:prenom => "Etienne", :nom => "Puydebois"}
	erb :eleve_identite, :locals => fiche_eleve
end

post '/eleve_scolarite_anterieure' do
	erb :eleve_scolarite_anterieure
end

get '/eleve_scolarite_anterieure' do
	erb :eleve_scolarite_anterieure
end

post '/famille_resp_legal_1' do
	erb :famille_resp_legal_1
end

get '/famille_resp_legal_1' do
	erb :famille_resp_legal_1
end

post '/famille_contact_urgence' do
	erb :famille_contact_urgence
end

get '/famille_contact_urgence' do
	erb :famille_contact_urgence
end

post '/choix_pedagogiques' do
	erb :choix_pedagogiques
end

get '/choix_pedagogiques' do
	erb :choix_pedagogiques
end

post '/renseignements_administratifs' do
	erb :renseignements_administratifs
end

get '/renseignements_administratifs' do
	erb :renseignements_administratifs
end

post '/pieces_a_joindre' do
	erb :pieces_a_joindre
end

get '/pieces_a_joindre' do
	erb :pieces_a_joindre
end