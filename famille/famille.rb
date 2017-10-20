require 'sinatra'

get '/tableau_de_bord' do
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

post '/validation' do

end