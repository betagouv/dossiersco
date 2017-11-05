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