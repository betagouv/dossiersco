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

post '/validation' do

end