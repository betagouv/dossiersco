require 'sinatra'
require 'json'
require 'sinatra/activerecord'

require './helpers/models.rb'
require './config/initializers/carrierwave.rb'
require './uploaders/fichier_uploader.rb'

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
		session[:erreur_id_ou_date_naiss_absente] = true
		redirect '/'
	end
	dossier_eleve = get_dossier_eleve params[:identifiant]
  if dossier_eleve.nil?
    session[:erreur_id_ou_date_naiss_incorrecte] = true
    redirect '/'
  end
  eleve = dossier_eleve.eleve
	if eleve.date_naiss == normalise(params[:date_naiss])
		session[:identifiant] = params[:identifiant]
		session[:demarche] = dossier_eleve.demarche
		redirect "/#{dossier_eleve.etape}"
	else
		session[:erreur_id_ou_date_naiss_incorrecte] = true
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
      eleve.option << Option.find_by(nom: nom_option, etablissement_id: eleve.dossier_eleve.etablissement.id)
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

	erb :'3_famille'
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
  dossier_eleve.check_reglement_cantine = params['check_reglement_cantine']
  dossier_eleve.check_paiement_cantine = params['check_paiement_cantine']
	dossier_eleve.save!
  if dossier_eleve.demi_pensionnaire &&
      (!dossier_eleve.check_reglement_cantine || !dossier_eleve.check_paiement_cantine)
    erb :'4_administration', locals: {dossier_eleve: dossier_eleve}
  else
	  sauve_et_redirect dossier_eleve, 'pieces_a_joindre'
  end
end

get '/pieces_a_joindre' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'5_pieces_a_joindre', locals: {dossier_eleve: dossier_eleve}
end

post '/pieces_a_joindre' do
	dossier_eleve = get_dossier_eleve session[:identifiant]
	fichiers = ["photo_identite", "assurance_scolaire", "jugement_garde_enfant"]
	fichiers.each do |f|
		if params[f].present? and params[f]["tempfile"].present?
			file = File.open(params[f]["tempfile"])
			uploader = FichierUploader.new
			uploader.store!(file)
			dossier_eleve[f] = uploader.url + File.basename(file.path)
		end
	end
	dossier_eleve.save!
	sauve_et_redirect dossier_eleve, 'validation'
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

def sauve_et_redirect dossier_eleve, etape
  dossier_eleve.etape = etape
  dossier_eleve.save!
  redirect "/#{etape}"
end