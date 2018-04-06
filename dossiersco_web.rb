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
set :session_secret, "secret"
use Rack::Session::Pool

identite_resp_legal = ["lien_de_parente", "prenom", "nom", "adresse", "code_postal", "ville", "tel_principal",
											 "tel_secondaire", "email", "situation_emploi", "profession", "enfants_a_charge",
											 "enfants_a_charge_secondaire", "communique_info_parents_eleves", "lien_avec_eleve"]

get '/init' do
  init
end

get '/' do
	erb :'#_identification', layout: false
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
		redirect "/accueil"
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
  erb :'1_eleve', locals: { eleve: eleve }
end

# pertinant de garder l'identifiant dans l'url ?
post '/eleve' do
  eleve = get_eleve session[:identifiant]
	identite_eleve = ['prenom', 'nom', 'sexe', 'ville_naiss', 'pays_naiss', 'nationalite', 'classe_ant', 'ets_ant']
	identite_eleve.each do |info|
		eleve[info] = params[info] if params.has_key?(info)
  end

  eleve.save!
  redirect '/scolarite'
end

get '/scolarite' do
  dossier_eleve = get_dossier_eleve session[:identifiant]
	erb :'2_scolarite', locals: {eleve: dossier_eleve.eleve}
end

post '/scolarite' do
	eleve = get_eleve session[:identifiant]
	enseignements_eleve = ['lv2']
	enseignements_eleve.each do |enseignement|
		eleve[enseignement] = params[enseignement] if params.has_key?(enseignement)
  end
  if eleve.save!
    redirect '/famille'
  else
    redirect '/scolarite'
  end
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
	redirect '/administration'
end

get '/administration' do
	erb :'4_administration'
end

post '/administration' do
	redirect '/pieces_a_joindre'
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
			p uploader.inspect
			dossier_eleve[f] = uploader.url + File.basename(file.path)
		end
	end
	dossier_eleve.save!
	redirect '/validation'
end

get '/validation' do
	eleve = get_eleve session[:identifiant]
	erb :'6_validation', locals: { eleve: eleve }
end

get '/confirmation' do
	erb :'7_confirmation'
end

# REINSCRIPTIONS

get '/r0' do
	erb :'r0_accueil'
end

get '/r1' do
	erb :'r1_scolarite'
end

get '/r2' do
	erb :'r2_famille'
end

get '/r3' do
	erb :'4_administration'
end

get '/r4' do
	erb :'5_pieces_a_joindre'
end

get '/r5' do
	erb :'6_validation'
end

get '/r6' do
	erb :'7_confirmation'
end
