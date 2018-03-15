ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'

require_relative '../dossiersco_web'

class EleveFormTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	def setup
		get '/init'
	end

	def test_accueil
		get '/'
		assert last_response.body.include? 'Inscription'
	end

	def test_entree_succes_eleve_1
		post '/identification', identifiant: '1', date_naiss: '1995-11-19'
		follow_redirect!
		assert last_response.body.include? 'Etienne'
		assert last_response.body.include? 'Georges Courteline (Paris 12ème)'
	end

	def test_entree_succes_eleve_2
		post '/identification', identifiant: '2', date_naiss: '1915-12-19'
		follow_redirect!
		assert last_response.body.include? 'Edith'
		assert last_response.body.include? 'Jean Lurçat (Brive-la-Gaillarde)'
	end

	def test_modification_lieu_naiss_eleve
		post '/identification', identifiant: '2', date_naiss: '1915-12-19'
		post '/eleve/2', ville_naiss: 'Beziers', prenom: 'Edith'
		get '/eleve/2'
		assert last_response.body.include? 'Edith'
		assert last_response.body.include? 'Beziers'
	end

	def test_modifie_une_information_de_eleve_preserve_les_autres_informations
		post '/identification', identifiant: '2', date_naiss: '1915-12-19'
		post '/eleve/2', prenom: 'Edith'
		get '/eleve/2'
		assert last_response.body.include? 'Piaf'
	end

	def test_passage_de_eleve_vers_scolarite
		post '/eleve/2'
		follow_redirect!
		assert last_response.body.include? 'Enseignement obligatoire'
	end

	def test_accueil_et_inscription
		post '/identification', identifiant: '2', date_naiss: '1915-12-19'
		follow_redirect!
		assert last_response.body.include? 'son inscription'
	end

	def test_accueil_et_réinscription
		post '/identification', identifiant: '1', date_naiss: '1995-11-19'
		follow_redirect!
		assert last_response.body.include? 'réinscription'
	end

	def teardown
		get '/init'
	end
end
