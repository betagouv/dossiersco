require 'sinatra'
require 'sinatra/activerecord'

set :database_file, "config/database.yml"

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool


get '/agent' do
	erb :'agent/identification'
end

post '/agent' do

  redirect '/tableau_de_bord'
end

get '/tableau_de_bord' do

  erb :'agent/tableau_de_bord'
end


