ENV['RACK_ENV'] = 'test'

require 'nokogiri'
require 'test/unit'
require 'rack/test'
require 'tempfile'

require_relative '../helpers/singulier_francais'

require_relative '../dossiersco_web'
require_relative '../dossiersco_agent'

class EleveFormTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include MotDePasse

  def app
    Sinatra::Application
  end

  def setup
    ActiveRecord::Schema.verbose = false
    require_relative "../db/schema.rb"
    init
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.deliveries = []
  end
  def test_affichage_preview_pdf_famille
    eleve = Eleve.find_by(identifiant: 6)
    piece_attendue = PieceAttendue.find_by(code: 'assurance_scolaire',
      etablissement_id: eleve.dossier_eleve.etablissement.id)
    piece_jointe = PieceJointe.create(clef: 'assurance_scannee.pdf', dossier_eleve_id: eleve.dossier_eleve.id,
      piece_attendue_id: piece_attendue.id)
    post '/identification', identifiant: '6', annee: '1970', mois: '01', jour: '01'
    get '/pieces_a_joindre'
    doc = Nokogiri::HTML(last_response.body)
    documents_route = FichierUploader::route_lecture '6', 'assurance_scolaire'
    expected_url = documents_route+"/assurance_scannee.pdf"
    assert_equal "background-image: url('/images/document-pdf.png'); height: 200px; max-width: 350px;",
                 doc.css("#image_assurance_scolaire").attr("style").text
    assert doc.css('#image_assurance_scolaire').attr("class").text.split.include?("lien-piece-jointe")
    assert_equal "modal", doc.css('#image_assurance_scolaire').attr("data-toggle").text
    assert_equal "#modal-pieces-jointes", doc.css('#image_assurance_scolaire').attr("data-target").text
    assert_equal expected_url, doc.css('#image_assurance_scolaire').attr("data-url").text
  end

  def test_une_personne_non_identifiée_ne_peut_accéder_à_pièces
    get "/piece/6/assurance_scolaire/nimportequoi"

    assert_equal 302, response.status
  end

  def assert_file(chemin_du_fichier)
    assert File.file? chemin_du_fichier
    File.delete(chemin_du_fichier)
  end

  def test_affiche_404
    # Sans identification, on est redirigé vers l'identification
    get '/unepagequinexistepas'
    assert last_response.redirect?

    post '/identification', identifiant: '5', annee: '1970', mois: '01', jour: '01'
    get '/unepagequinexistepas'
    assert last_response.body.include? "une page qui n'existe pas"
  end

  def test_erreur_interne
    Sinatra::Application::set :environment, 'production'
    get '/unepagequileveuneexception'
    assert last_response.body.include? "une erreur technique"
    Sinatra::Application::set :environment, 'development'
  end

end
