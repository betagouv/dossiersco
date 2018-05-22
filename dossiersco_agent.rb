require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require_relative 'helpers/singulier_francais'
require_relative 'helpers/import_siecle'
require_relative 'helpers/agent'
require_relative 'helpers/pdf'

configure :staging, :production do
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end

set :database_file, "config/database.yml"

enable :sessions
set :session_secret, "secret"
use Rack::Session::Pool

before '/agent/*' do
  redirect '/agent' unless agent.present?
end

get '/agent' do
  erb :'agent/identification'
end

post '/agent' do
  agent = Agent.find_by(identifiant: params[:identifiant])
  mdp_saisi = params[:mot_de_passe]
  mdp_crypte = BCrypt::Password.new(agent.password)
  if mdp_crypte == mdp_saisi
    session[:identifiant] = agent.identifiant
    redirect '/agent/tableau_de_bord'
  else
    session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
    redirect '/agent'
  end
end

get '/agent/liste_des_eleves' do
  erb :'agent/liste_des_eleves',
      layout: :layout_agent,
      locals: {agent: agent, dossier_eleves: agent.etablissement.dossier_eleve}
end

get '/agent/tableau_de_bord' do
  total_dossiers = agent.etablissement.dossier_eleve.count
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent, total_dossiers: total_dossiers}
end

get '/agent/import_siecle' do
  tache = agent.etablissement.tache_import.last
  erb :'agent/import_siecle', layout: :layout_agent, locals: {agent: agent, tache: tache, message: ""}
end

post '/agent/import_siecle' do
  tempfile = params[:filename][:tempfile]
  tempfile = tempfile.path if tempfile.respond_to? :path
  file = File.open(tempfile)
  uploader = FichierUploader.new
  uploader.store!(file)
  fichier_s3 = get_fichier_s3 File.basename(tempfile)
  tache = TacheImport.create(
    url: fichier_s3.url(Time.now.to_i + 1200),
    etablissement_id: agent.etablissement.id,
    statut: 'en_attente',
    nom_a_importer: params[:nom_eleve],
    prenom_a_importer: params[:prenom_eleve])
  erb :'agent/import_siecle',
      locals: { message: "",
          tache: tache
      }, layout: :layout_agent
end

get '/api/traiter_imports' do
  traiter_imports
end

get '/agent/eleve/:identifiant' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  erb :'agent/eleve', locals: {agent: agent, eleve: eleve }, layout: :layout_agent
end

post '/agent/change_etat_fichier' do
  piece = PieceJointe.find(params[:id])
  piece.update(etat: params[:etat])
end

get '/agent/options' do
  etablissement = agent.etablissement
  options = etablissement.option
  erb :'agent/options', locals: {agent: agent, options: options}, layout: :layout_agent
end

post '/agent/options' do
  etablissement = agent.etablissement
  option = Option.find_by(
    nom: params[:nom].upcase.capitalize,
    niveau_debut: params[:niveau_debut],
    etablissement: etablissement.id)

  if !params[:nom].present?
    message = "Une option doit comporter un nom"
    erb :'agent/options', locals: {options: etablissement.option, message: message},
    layout: :layout_agent
  elsif !params[:niveau_debut].present?
    message = "Une option doit comporter un niveau de début"
    erb :'agent/options', locals: {options: etablissement.option, message: message},
    layout: :layout_agent
  elsif option.present? && (option.nom == params[:nom].upcase.capitalize) && (option.niveau_debut == params[:niveau_debut].to_i)
    message = "#{params[:nom]} existe déjà pour le niveau #{params[:niveau_debut]}ème"
    erb :'agent/options', locals: {options: etablissement.option, message: message},
    layout: :layout_agent
  else
    option = Option.create!(
       nom: params[:nom].upcase.capitalize,
       niveau_debut: params[:niveau_debut],
       etablissement_id: etablissement.id,
       obligatoire: params[:obligatoire],
       groupe: params[:groupe].present? ? params[:groupe].capitalize : 'Option')
    erb :'agent/options',
      locals: {options: etablissement.option, agent: agent}, layout: :layout_agent
  end
end

get '/agent/piece_attendues' do
  etablissement = agent.etablissement
  piece_attendues = etablissement.piece_attendue
  erb :'agent/piece_attendues', locals: {agent: agent, piece_attendues: piece_attendues}, layout: :layout_agent
end

post '/agent/piece_attendues' do
  etablissement = agent.etablissement
  code_piece = params[:nom].gsub(/[^a-zA-Z0-9]/, '_').upcase.downcase
  piece_attendue = PieceAttendue.find_by(
    code: code_piece,
    etablissement: etablissement.id)

  if !params[:nom].present?
    message = "Une pièce doit comporter un nom"
    erb :'agent/piece_attendues', locals: {piece_attendues: etablissement.piece_attendue, message: message},
    layout: :layout_agent

  elsif piece_attendue.present? && (piece_attendue.nom == code_piece)
    message = "#{params[:nom]} existe déjà"
    erb :'agent/piece_attendues', locals: {piece_attendues: etablissement.piece_attendue, message: message},
    layout: :layout_agent
  else
    piece_attendue = PieceAttendue.create!(
       nom: params[:nom],
       explication: params[:explication],
       obligatoire: params[:obligatoire],
       etablissement_id: etablissement.id,
       code: code_piece)
    erb :'agent/piece_attendues',
      locals: {piece_attendues: etablissement.piece_attendue, agent: agent}, layout: :layout_agent
  end
end

get '/agent/export' do
  erb :'agent/export',
  locals: {agent: agent}, layout: :layout_agent
end

post '/agent/supprime_option' do
  Option.find(params[:option_id]).delete
end

post '/agent/supprime_piece_attendue' do
  pieces_existantes = PieceJointe.where(piece_attendue_id: params[:piece_attendue_id])
  if pieces_existantes.size >= 1
    message = 'Cette piece ne peut être supprimé'
    raise
  else
    PieceAttendue.find(params[:piece_attendue_id]).delete
  end
end

get '/agent/pdf' do
  erb :'agent/courrier', :layout_agent
end

post '/agent/pdf' do
  content_type 'application/pdf'
  eleve = Eleve.find_by identifiant: params[:identifiant]
  pdf = genere_pdf eleve
  agent = Agent.find_by(identifiant: session[:identifiant])
  pdf.render
end
