# frozen_string_literal: true

require "net/http"

class AuthentificationCasEntController < ApplicationController

  before_action :identification_agent, only: "debug_ent"

  def new
    render layout: false
  end

  def appel_direct_ent
    redirect_to "#{ENV['ENT_PARIS_URL']}/login?service=#{ENV['ENT_PARIS_URL_RETOUR']}"
  end

  def retour_cas
    data = donnees_ent(params[:ticket])["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]
    responsables = []
    retrouve_liste_resp_legal(data).each { |resp_legal| responsables << resp_legal }

    (identifie_et_redirige(responsables.first.dossier_eleve) && return) if responsables.count == 1
    (rendre_choix_dossier_eleve(responsables) && return) if responsables.count > 1
    dossier_non_trouve(data, nil, Exception.new("Pas de responsable legal trouvé"))
  rescue StandardError
    dossier_non_trouve(nil, params, Exception.new("Problème d'extraction de donnée"))
  end

  def rendre_choix_dossier_eleve(responsables)
    @resp_legals = responsables
    render :choix_dossier_eleve, layout: "connexion"
  end

  def dossier_non_trouve(data, params, exception)
    Raven.extra_context data: data if data
    if params
      Raven.extra_context params: params
      Raven.extra_context donnee: donnees_ent(params[:ticket])
    end
    Raven.capture_exception(exception)
    flash[:alert] = I18n.t(".dossier_non_trouve")
    redirect_to "/"
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

  def identifie_et_redirige(dossier_eleve)
    session[:identifiant] = dossier_eleve.identifiant

    if dossier_eleve.derniere_etape.present?
      redirect_to("/#{dossier_eleve.derniere_etape}")
    elsif dossier_eleve.etape_la_plus_avancee.present?
      redirect_to("/#{dossier_eleve.etape_la_plus_avancee}")
    else
      redirect_to("accueil")
    end
  end

  def retrouve_liste_resp_legal(data)
    return [] unless data.is_a?(Hash)

    email = data["email"]
    return RespLegal.where("lower(email) = ?", email.downcase) if email && email != { "xmlns" => "" }

    responsables_sans_email
  end

  def responsables_sans_email
    responsables = RespLegal.where("lower(prenom) = ?", data["firstName"].downcase)
    nom = data["lastName"]
    responsables = query.where("lower(nom) = ?", nom.downcase) if nom != { "xmlns" => "" }
    if responsables.count > 1
      adresse = data["address"]
      responsables = query.where("lower(adresse) = ?", adresse.downcase) if adresse != { "xmlns" => "" }
    end
    responsables
  end

  def debug_ent
    if super_admin?(@agent_connectes)
      render xml: donnees_ent(params[:ticket])
    else
      render text: "aucun resultat sans le bon mot de passe"
    end
  end

end
