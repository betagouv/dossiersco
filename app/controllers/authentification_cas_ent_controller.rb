# frozen_string_literal: true

require "net/http"

class AuthentificationCasEntController < ApplicationController

  before_action :identification_agent, only: "debug_ent"

  def new
    render layout: false
  end

  def identifie_et_redirige(dossier_eleve)
    session[:identifiant] = dossier_eleve.eleve.identifiant

    if dossier_eleve.derniere_etape.present?
      redirect_to("/#{dossier_eleve.derniere_etape}")
    elsif dossier_eleve.etape_la_plus_avancee.present?
      redirect_to("/#{dossier_eleve.etape_la_plus_avancee}")
    else
      redirect_to("accueil")
    end
  end

  def retour_cas
    data = donnees_ent(params[:ticket])
    responsables = retrouve_les_responsables_legaux_depuis(data)

    if un_seul_dossier_correspondant(responsables, data)
      identifie_et_redirige(responsables.first.dossier_eleve)
    elsif plusieurs_responsables_legaux?(responsables)
      @resp_legals = responsables
      render :choix_dossier_eleve, layout: "connexion"
    else
      Raven.extra_context data: data
      Raven.capture_exception(Exception.new("Dossier ENT non trouvé"))
      flash[:alert] = I18n.t(".dossier_non_trouve")
      redirect_to "/"
    end
  end

  def retrouve_les_responsables_legaux_depuis(data)
    resp_legals = []
    retrouve_liste_resp_legal(data).each do |resp_legal|
      resp_legals << resp_legal
    end
    resp_legals
  end

  def un_seul_dossier_correspondant(responsables, data)
    un_seul_responsable_legal?(responsables) &&
      eleve_et_etablissement_correspondant?(responsables.first.dossier_eleve, data)
  end

  def un_seul_responsable_legal?(resp_legals)
    resp_legals.length == 1 && resp_legals[0].dossier_eleve
  end

  def plusieurs_responsables_legaux?(resp_legals)
    resp_legals.length > 1
  end

  def choix_dossier
    resp_legal = RespLegal.find(params[:resp_legal])

    dossier_eleve = resp_legal.dossier_eleve

    if dossier_eleve.present?
      dossier_eleve.update(etat: "connecté") if dossier_eleve.etat == "pas connecté"
      identifie_et_redirige(dossier_eleve)
    else
      session[:message_erreur] = t("identification.erreurs.identifiants_inconnus")
      redirect_to root_path
    end
  end

  def donnees_ent(ticket)
    uri = URI("#{ENV['ENT_PARIS_URL']}/serviceValidate")
    params = { service: ENV["ENT_PARIS_URL_RETOUR"], ticket: ticket }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri)
      http.request(req)
    end
    Hash.from_xml(res.body)
  end

  def eleve_et_etablissement_correspondant?(dossier_eleve, data)
    etablissement_correspondant?(dossier_eleve, data) &&
      eleve_correspondant?(dossier_eleve, data)
  end

  def etablissement_correspondant?(dossier_eleve, data)
    etablissements = retrouve_etablissements(data)
    etablissements.include?(dossier_eleve.etablissement)
  end

  def eleve_correspondant?(dossier_eleve, data)
    enfants = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["children"]
    eleves = JSON.parse(enfants).map { |e| e["displayName"] }
    eleves.include?("#{dossier_eleve.eleve.nom.upcase} #{dossier_eleve.eleve.prenom}")
  end

  def retrouve_etablissements(data)
    etablissements = JSON.parse(data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["structureNodes"])
    Etablissement.where("uai in (?)", etablissements.map { |e| e["UAI"] })
  end

  def retrouve_liste_resp_legal(data)
    attributes = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]

    email = attributes["email"]
    if email != { "xmlns" => "" }
      query = RespLegal.where(email: email)
    else
      query = RespLegal.where(prenom: attributes["firstName"])
      nom = attributes["lastName"]
      query = query.where(nom: nom) if nom != { "xmlns" => "" }
      adresse = attributes["address"]
      query = query.where(adresse: adresse) if adresse != { "xmlns" => "" }
    end
    query
  end

  def appel_direct_ent
    redirect_to "#{ENV['ENT_PARIS_URL']}/login?service=#{ENV['ENT_PARIS_URL_RETOUR']}"
  end

  def debug_ent
    if @agent_connecte.super_admin?
      render xml: donnees_ent(params[:ticket])
    else
      render text: "aucun resultat sans le bon mot de passe"
    end
  end

end
