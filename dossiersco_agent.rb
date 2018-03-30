require 'sinatra'
require 'sinatra/activerecord'

set :database_file, "config/database.yml"

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool


get '/agent' do
	erb :'agent'
end
