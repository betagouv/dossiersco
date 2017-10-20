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
	erb :affectation
end

post '/inscription' do
	erb :inscription
end

post '/refus' do
	erb :refus
end

post '/eleve' do
	fiche_eleve = {:prenom => "Etienne", :nom => "Puydebois"}
	erb :eleve, :locals => fiche_eleve
end