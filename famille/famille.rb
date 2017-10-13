require 'sinatra'

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
	erb :eleve, :locals => {:prenom => "Etienne"}
end

post '/validation' do

end