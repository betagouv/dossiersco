ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'

require_relative '../dossiersco_web'

class EleveFormTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	def test_accueil
		get '/'
		assert last_response.body.include? 'Inscription'
	end

	def test_entree_succes
		post '/accueil', identifiant: '1', date_naiss: '1995-11-19'
		assert last_response.body.include? 'Etienne'
	end
	
	def test_entree_echec
		post '/accueil', identifiant: '3'
		follow_redirect!
		assert last_response.body.include? 'aucun élève'
	end

	def test_modification_lieu_naiss_eleve
		get '/init'
		post '/accueil', identifiant: '2'
		post '/eleve', ville_naiss: 'Beziers'
		get '/eleve'
		assert last_response.body.include? 'Elodie'
		assert last_response.body.include? 'Beziers'
	end

	# def test_mauvaise_connexion
	# 	get '/eleve?'
	# 	follow_redirect!
	# 	assert last_response.body.include? 'Quelques clics'
	# end
end