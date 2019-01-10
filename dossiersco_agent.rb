require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'tilt/erb'

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


get '/agent/deconnexion' do
  session.clear
  redirect '/agent'
end


get '/agent/tableau_de_bord' do
  total_dossiers = agent.etablissement.dossier_eleve.count
  etats, notes, moyenne, dossiers_avec_commentaires = agent.etablissement.stats
  erb :'agent/tableau_de_bord',
    layout: :layout_agent,
    locals: {agent: agent, total_dossiers: total_dossiers, etats: etats,
      notes: notes, moyenne: moyenne, dossiers_avec_commentaires: dossiers_avec_commentaires.sort_by(&:date_signature).reverse}
end

post '/agent/tableau_de_bord' do
  agent.update(etablissement_id: params[:etablissement])
  redirect '/agent/tableau_de_bord'
end

get '/agent/eleve/:identifiant' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  dossier_eleve = eleve.dossier_eleve
  emails_presents = false
  resp_legaux = dossier_eleve.resp_legal
  resp_legaux.each { |r| (emails_presents = true) if r.email.present?}
  meme_adresse = resp_legaux.first.meme_adresse resp_legaux.second
  modeles = agent.etablissement.modele
  erb :'agent/eleve', layout: :layout_agent,
    locals: {
      emails_presents: emails_presents,
      agent: agent,
      modeles: modeles,
      eleve: eleve,
      dossier_eleve: dossier_eleve,
      meme_adresse: meme_adresse}
end

post '/agent/pieces_jointes_eleve/:identifiant' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  dossier_eleve = eleve.dossier_eleve
  upload_pieces_jointes dossier_eleve, params, 'valide'
  redirect "/agent/eleve/#{eleve.identifiant}#dossier"
end

get '/agent/options' do
  etablissement = agent.etablissement
  eleves_par_classe = DossierEleve.where(etablissement_id: etablissement.id).collect(&:eleve).group_by(&:niveau_classe_ant)
  eleves = Eleve.all.select {|e| e.dossier_eleve.etablissement_id == etablissement.id && e.dossier_eleve.etat != 'sortant'}
  nb_max_options = 0
  eleves.each do |e|
    nb_max_options = e.options_apres_montee.count if e.options_apres_montee.count > nb_max_options
  end

  erb :'agent/options', locals: {agent: agent,etablissement: etablissement, eleves_par_classe: eleves_par_classe,
    eleves: eleves, nb_max_options: nb_max_options}, layout: :layout_agent
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
  dossier_eleve.valide

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
  dossier_eleve = eleve.dossier_eleve
  emails_presents = false
  resp_legaux = dossier_eleve.resp_legal
  resp_legaux.each { |r| (emails_presents = true) if r.email.present?}
  session[:message_info] = "Votre message ne peut être acheminé."
  if emails_presents
    mail = AgentMailer.contacter_une_famille(eleve, params[:message])
    part = mail.html_part || mail.text_part || mail
    Message.create(categorie:"mail", contenu: part.body, etat: "envoyé", dossier_eleve: eleve.dossier_eleve)
    mail.deliver_now
    session[:message_info] = "Votre message a été envoyé."
  elsif dossier_eleve.portable_rl1.present?
    Message.create(categorie:"sms",
        contenu: params[:message],
        destinataire: params[:destinataire] || "rl1",
        etat: "en attente",
        dossier_eleve: eleve.dossier_eleve)
    session[:message_info] = "Votre message est en attente d'expédition."
  end
  redirect "/agent/liste_des_eleves"
end

get '/agent/relance' do
  ids = params["ids"].split(',')
  emails, telephones  = [], []

  ids.each do |id|
    dossier = DossierEleve.find(id)
    emails << dossier.resp_legal_1.email
    telephones << dossier.portable_rl1
  end

  erb :'agent/relance',
    layout: :layout_agent,
    locals: {ids: ids, emails: emails, telephones: telephones}
end

post '/agent/relance_emails' do
  template = params[:template]
  ids = params[:ids].split(',')
  dossier_eleves = []

  ids.each do |id|
    dossier = DossierEleve.find(id)
    template = Tilt['erb'].new { template }
    contenu = template.render(nil, eleve: dossier.eleve)
    Message.create(categorie:"mail",
      contenu: contenu,
      etat: "en attente",
      dossier_eleve: dossier)
  end

  redirect '/agent/liste_des_eleves'
end

post '/agent/relance_sms' do
  template = params[:template]
  ids = params[:ids].split(',')
  ids.each do |id|
    DossierEleve.find(id).relance_sms template
  end
  redirect '/agent/liste_des_eleves'
end

post '/agent/valider_plusieurs_dossiers' do
  ids = params["ids"]
  ids.each do |id|
    DossierEleve.find(id).valide
  end
  redirect '/agent/liste_des_eleves'
end

get '/agent/fusionne_modele/:modele_id/eleve/:identifiant' do
  eleve = Eleve.find_by(identifiant: params[:identifiant])
  modele = Modele.find(params[:modele_id])
  template = Tilt['erb'].new { modele.contenu }
  template.render(nil, eleve: eleve)
end

get '/agent/convocations' do
  etablissement = agent.etablissement
  eleves = Eleve.all.select do |e|
    d = e.dossier_eleve
    d.etablissement_id == etablissement.id && (d.etat == 'pas connecté' || d.etat == 'connecté')
  end

  erb :'agent/convocations', locals: {agent: agent,etablissement: etablissement, eleves: eleves}, layout: :layout_agent
end

get '/agent/creer_etablissement' do
  redirect '/agent' unless agent.admin

  erb :'agent/creer_etablissement'
end

post '/agent/creer_etablissement' do
  Etablissement.create!(params)

  redirect "/agent/creer_agent"
end

get '/agent/creer_agent' do
  redirect '/agent' unless agent.admin

  erb :'agent/creer_agent'
end

post '/agent/creer_agent' do
  a = Agent.create!(params)
  a.password = BCrypt::Password.create(params[:password])
  a.save!
  redirect "/agent/liste_des_eleves"
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
