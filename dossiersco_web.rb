require 'sinatra'
require 'json'
require 'sinatra/activerecord'

require './helpers/models.rb'
require './config/initializers/carrierwave.rb'
require './uploaders/fichier_uploader.rb'
require './helpers/s3.rb'

set :database_file, "config/database.yml"

require_relative 'helpers/formulaire'
require_relative 'helpers/init'
require_relative 'helpers/mot_de_passe'

enable :sessions
use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => SecureRandom.base64(10)

identite_resp_legal = ["lien_de_parente", "prenom", "nom", "adresse", "code_postal", "ville", "tel_principal",
											 "tel_secondaire", "email", "situation_emploi", "profession", "enfants_a_charge",
											 "enfants_a_charge_secondaire", "communique_info_parents_eleves", "lien_avec_eleve"]

get '/init' do
  init
end

get '/' do
	erb :'#_identification'
end

post '/identification' do
	if params[:identifiant].empty? || params[:date_naiss].empty?
		session[:message_erreur] = "Veuillez renseigner l'identifiant et la date de naissance de l'élève."
		redirect '/'
	end
	dossier_eleve = get_dossier_eleve params[:identifiant]
  if dossier_eleve.nil?
    session[:message_erreur] = message_erreur_identification params[:identifiant], params[:date_naiss]
    redirect '/'
  end
  eleve = dossier_eleve.eleve
	if eleve.date_naiss == normalise(params[:date_naiss])
		session[:identifiant] = params[:identifiant]
		session[:demarche] = dossier_eleve.demarche
		redirect "/#{dossier_eleve.etape}"
	else
		session[:message_erreur] = message_erreur_identification params[:identifiant], params[:date_naiss]
		redirect '/'
	end
end

get '/accueil' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'0_accueil', locals: { dossier_eleve: dossier_eleve }
end

get '/eleve' do
  eleve = get_eleve session[:identifiant]
  options = options_du_niveau_classees eleve, eleve.dossier_eleve.etablissement.id
  options_obligatoires = {}
  options[:obligatoire].each do |option|
    option_du_groupe = options_obligatoires[option[:groupe]]
    if option_du_groupe.nil?
      options_obligatoires[option[:groupe]] = [option]
    else
      option_du_groupe << option
    end
  end
  erb :'1_eleve', locals: { eleve: eleve,
   options_obligatoires: options_obligatoires,
   options_facultatives: options[:facultative] }
end

post '/eleve' do
  eleve = get_eleve session[:identifiant]
  identite_eleve = ['prenom', 'prenom_2', 'prenom_3', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
  options = options_du_niveau eleve, eleve.dossier_eleve.etablissement.id
  nom_options = options.map { |option| option.nom }
  identite_eleve.each do |info|
	 eleve[info] = params[info] if params.has_key?(info)
  end

  nom_options.each do |nom_option|
    if params.has_key?(nom_option) or params.has_value?(nom_option)
      option_choisit = Option.find_by(nom: nom_option, etablissement_id: eleve.dossier_eleve.etablissement.id)
      eleve.option << option_choisit unless eleve.option.include? option_choisit
    else
      eleve.option.delete eleve.option.select { |o| o.nom == nom_option }
    end
  end
  eleve.save!

  sauve_et_redirect eleve.dossier_eleve, 'famille'
end

get '/famille' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	resp_legal1 = RespLegal.find_by(dossier_eleve_id: dossier_eleve.id, priorite: 1)
	resp_legal2 = RespLegal.find_by(dossier_eleve_id: dossier_eleve.id, priorite: 2)
	contact_urgence = ContactUrgence.find_by(dossier_eleve_id: dossier_eleve.id)

	identite_resp_legal.each do |i|
		params["#{i}_rl1"] = resp_legal1[i] if !resp_legal1.nil? && !resp_legal1[i].nil?
		params["#{i}_rl2"] = resp_legal2[i] if !resp_legal2.nil? && !resp_legal2[i].nil?
		params["#{i}_urg"] = contact_urgence[i] if !contact_urgence.nil? && !contact_urgence[i].nil?
	end

  resp_legal_2 = dossier_eleve.resp_legal.select {|resp_legal| resp_legal.priorite == 2}.first

  erb :'3_famille', locals: {resp_legal_2: resp_legal_2, contact_urgence: dossier_eleve.contact_urgence}
end

post '/famille' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	resp_legal1 = RespLegal.find_by(dossier_eleve_id: dossier_eleve.id, priorite: 1) || RespLegal.new(priorite: 1, dossier_eleve_id: dossier_eleve.id)
	resp_legal2 = RespLegal.find_by(dossier_eleve_id: dossier_eleve.id, priorite: 2) || RespLegal.new(priorite: 2, dossier_eleve_id: dossier_eleve.id)
	contact_urgence = ContactUrgence.find_by(dossier_eleve_id: dossier_eleve.id) || ContactUrgence.new(dossier_eleve_id: dossier_eleve.id)

	identite_resp_legal.each do |i|
		resp_legal1[i] = params["#{i}_rl1"] if params.has_key?("#{i}_rl1")
		resp_legal2[i] = params["#{i}_rl2"] if params.has_key?("#{i}_rl2")
		contact_urgence[i] = params["#{i}_urg"] if params.has_key?("#{i}_urg")
	end

	resp_legal1.save!
	resp_legal2.save!
	contact_urgence.save!
	sauve_et_redirect dossier_eleve, 'administration'
end

get '/administration' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'4_administration', locals: {dossier_eleve: dossier_eleve}
end

post '/administration' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	dossier_eleve.demi_pensionnaire = params['demi_pensionnaire']
	dossier_eleve.autorise_sortie = params['autorise_sortie']
	dossier_eleve.renseignements_medicaux = params['renseignements_medicaux']
  dossier_eleve.check_paiement_cantine = params['check_paiement_cantine']
	dossier_eleve.save!
  if dossier_eleve.demi_pensionnaire && !dossier_eleve.check_paiement_cantine
    erb :'4_administration', locals: {dossier_eleve: dossier_eleve, message_cantine: "Vous devez accepter les conditions ci-dessus"}
  else
	  sauve_et_redirect dossier_eleve, 'pieces_a_joindre'
  end
end

get '/piece/:dossier_eleve/:code_piece/:s3_key' do
  dossier_eleve = get_dossier_eleve params[:dossier_eleve]

  # Vérifier les droits d'accès
  famille_autorisé = params[:dossier_eleve] == session[:identifiant]

  agent = Agent.find_by(identifiant: session[:identifiant])
  agent_autorisé = agent.present? and (dossier_eleve.etablissement == agent.etablissement)

  usager_autorisé = famille_autorisé || agent_autorisé

  objet_demandé = params[:s3_key]
  objet_présent = PieceJointe.find_by(dossier_eleve_id: dossier_eleve.id, clef: params[:s3_key])
  clef_objet_présent = objet_présent.clef if objet_présent.present?
  objet_conforme = objet_demandé == clef_objet_présent 

  if usager_autorisé and objet_conforme
    response.headers['Content-Type'] = ''
    fichier = get_fichier_s3(params[:s3_key])
    open fichier.url(Time.now.to_i + 30)
    # if params[:s3_key].end_with? 'pdf'
    #   content_type 'application/pdf'
    # elsif params[:s3_key].end_with? 'jpg' or params[:s3_key].end_with? 'jpeg'
    #   content_type 'image/jpeg'
    # elsif params[:s3_key].end_with? 'png'
    #   content_type 'image/png'
    # end
  else
    redirect '/'
  end
end

get '/pieces_a_joindre' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'5_pieces_a_joindre', locals: {dossier_eleve: dossier_eleve}
end

post '/enregistre_piece_jointe' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
  params.each do |code, piece|
    if params[code].present? and params[code]["tempfile"].present?
      file = File.open(params[code]["tempfile"])
      uploader = FichierUploader.new
      uploader.store!(file)
      nom_du_fichier = File.basename(file.path)
      piece_attendue = PieceAttendue.find_by(code: code, etablissement_id: dossier_eleve.etablissement_id)
      piece_jointe = PieceJointe.find_by(piece_attendue_id: piece_attendue.id, dossier_eleve_id: dossier_eleve.id)
      if piece_jointe.present?
        piece_jointe.update(etat: 'soumis', clef: nom_du_fichier)
      else
        piece_jointe = PieceJointe.create!(etat: 'soumis', clef: nom_du_fichier, piece_attendue_id: piece_attendue.id, dossier_eleve_id: dossier_eleve.id)
      end
    end
  end
  redirect '/pieces_a_joindre'
end

post '/pieces_a_joindre' do
	redirect '/validation'
end

get '/validation' do
	eleve = get_eleve session[:identifiant]
	dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'6_validation', locals: { eleve: eleve, dossier_eleve: dossier_eleve }
end

get '/confirmation' do
	eleve = get_eleve session[:identifiant]
	dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'7_confirmation', locals: { eleve: eleve, dossier_eleve: dossier_eleve }
end

post '/satisfaction' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
  dossier_eleve.satisfaction = params[:note]
  dossier_eleve.save!
end

post '/commentaire' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
  dossier_eleve.commentaire = params[:commentaire]
  dossier_eleve.save!
  redirect '/confirmation'
end


def sauve_et_redirect dossier_eleve, etape
  dossier_eleve.etape = etape
  dossier_eleve.save!
  redirect "/#{etape}"
end
