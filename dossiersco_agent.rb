require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

require './config/initializers/mailjet.rb'
require './config/initializers/actionmailer.rb'
require './config/initializers/carrierwave.rb'

require_relative 'helpers/singulier_francais'
require_relative 'helpers/import_siecle'
require_relative 'helpers/agent'
require_relative 'helpers/pdf'

require './mailers/agent_mailer.rb'

configure :staging, :production do
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end

set :database_file, "config/database.yml"

before '/agent/*' do
  agent_connecte = agent
  identifiant = agent_connecte.present? ? agent.identifiant : '<anonyme>'
  Trace.create(identifiant: identifiant,
    categorie: 'agent',
    page_demandee: request.path_info,
    adresse_ip: request.ip)
  redirect '/agent' unless agent.present?
end

get '/agent' do
  erb :'agent/identification'
end

get '/agent/deconnexion' do
  session.clear
  redirect '/agent'
end

post '/agent' do
  agent = Agent.find_by(identifiant: params[:identifiant])
  mdp_saisi = params[:mot_de_passe]
  if agent && (BCrypt::Password.new(agent.password) == mdp_saisi)
    session[:identifiant] = agent.identifiant
    redirect '/agent/liste_des_eleves'
  else
    session[:erreur_login] = "Ces informations ne correspondent pas à un agent enregistré"
    redirect '/agent'
  end
end

get '/agent/liste_des_eleves' do
  lignes_eleves = DossierEleve
    .joins(:eleve,:resp_legal)
    .select('dossier_eleves.id as dossier_id')
    .select('dossier_eleves.updated_at as dossier_maj')
    .select('dossier_eleves.*')
    .select('eleves.*')
    .select('resp_legals.email')
    .select('adresse,code_postal,ville,adresse_ant,code_postal_ant,ville_ant')
    .order('eleves.classe_ant DESC, dossier_eleves.etat, eleves.identifiant')
    .where(resp_legals:{priorite:1}, etablissement: agent.etablissement)
  pieces_jointes = PieceJointe
    .joins(:dossier_eleve,:piece_attendue)
    .select('dossier_eleves.id as dossier_id').select('piece_jointes.*')
    .where(piece_attendues:{etablissement_id: agent.etablissement.id})
    .group_by(&:dossier_eleve_id)
  message_info = session[:message_info]
  session.delete :message_info
  erb :'agent/liste_des_eleves',
      layout: :layout_agent,
      locals: {
          agent: agent,
          lignes_eleves: lignes_eleves,
          message_info: message_info,
          pieces_attendues: agent.etablissement.piece_attendue,
          pieces_jointes: pieces_jointes}
end

get '/agent/tableau_de_bord' do
  total_dossiers = agent.etablissement.dossier_eleve.count
  etats, notes, moyenne, dossiers_avec_commentaires = stats agent.etablissement
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent, total_dossiers: total_dossiers, etats: etats,
      notes: notes, moyenne: moyenne, dossiers_avec_commentaires: dossiers_avec_commentaires.sort_by(&:date_signature).reverse}
end

post '/agent/tableau_de_bord' do
  agent.update(etablissement_id: params[:etablissement])
  redirect '/agent/tableau_de_bord'
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
    prenom_a_importer: params[:prenom_eleve],
    traitement: params[:traitement])
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
  emails_presents = false
  dossier_eleve = eleve.dossier_eleve
  resp_legaux = dossier_eleve.resp_legal
  resp_legaux.each { |r| (emails_presents = true) if r.email.present?}
  meme_adresse = resp_legaux.first.meme_adresse resp_legaux.second
  erb :'agent/eleve', layout: :layout_agent,
    locals: {emails_presents: emails_presents, agent: agent, eleve: eleve, dossier_eleve: dossier_eleve, meme_adresse: meme_adresse}
end

post '/agent/change_etat_fichier' do
  piece = PieceJointe.find(params[:id])
  piece.update(etat: params[:etat])
end

get '/agent/options' do
  etablissement = agent.etablissement
  eleves_par_classe = DossierEleve.where(etablissement_id: etablissement.id).collect(&:eleve).group_by(&:niveau_classe_ant)

  erb :'agent/options', locals: {agent: agent,etablissement: etablissement, eleves_par_classe: eleves_par_classe}, layout: :layout_agent
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

post '/agent/valider_inscription' do
  eleve = Eleve.find_by identifiant: params[:identifiant]
  dossier_eleve = eleve.dossier_eleve
  emails = dossier_eleve.resp_legal.map{ |resp_legal| resp_legal.email }
  dossier_eleve.update(etat: 'validé')
  mail = AgentMailer.mail_validation_inscription(eleve)
  mail.deliver_now

  redirect "/agent/liste_des_eleves"
end

post '/agent/eleve_sortant' do
  eleve = Eleve.find_by identifiant: params[:identifiant]
  dossier_eleve = eleve.dossier_eleve
  dossier_eleve.update(etat: 'sortant')

  redirect "/agent/liste_des_eleves"
end

post '/agent/contacter_une_famille' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  mail = AgentMailer.contacter_une_famille(eleve, params[:message])
  part = mail.html_part || mail.text_part || mail
  Message.create(categorie:"mail", contenu: part.body, etat: "envoyé", dossier_eleve: eleve.dossier_eleve, resultat: "")
  mail.deliver_now
  session[:message_info] = "Votre message a été envoyé."
  redirect "/agent/liste_des_eleves"
end

get '/agent/relance' do
  ids = params["ids"]
  erb :'agent/courrier', :layout_agent
end

# tester cette route
#
post '/agent/valider_plusieurs_dossiers' do
  ids = params["ids"]
  ids.each do |id|
    DossierEleve.find(id.to_i).update(etat: 'validé')
  end
  redirect '/agent/liste_des_eleves'
end

# Route de test uniquement
get '/agent/testmail/:nom' do
  class TestMailer < ActionMailer::Base
    default from: "contact@dossiersco.beta.gouv.fr"
    default to: "contact@dossiersco.beta.gouv.fr"
    def testmail(nom)
      @nom = nom
      mail(subject: "Test") do |format|
        format.text
      end
    end
  end
  nom = params[:nom] || 'testeur'
  mail = TestMailer.testmail(nom)
  mail.deliver_now
end


