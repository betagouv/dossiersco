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
    retrouve_liste_resp_legal(data).each do |resp_legal|
      responsables << resp_legal
    end

    if responsables.count == 1
      identifie_et_redirige(responsables.first.dossier_eleve)
    elsif responsables.count > 1
      @resp_legals = responsables
      render :choix_dossier_eleve, layout: "connexion"
    else
      Raven.extra_context data: data
      Raven.capture_exception(Exception.new("Pas de responsable legal trouvé"))
      flash[:alert] = I18n.t(".dossier_non_trouve")
      redirect_to "/"
    end
  rescue StandardError
    Raven.extra_context params: params
    Raven.extra_context donnee: donnees_ent(params[:ticket])
    Raven.capture_exception(Exception.new("Problème d'extraction de donnée"))
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
    session[:identifiant] = dossier_eleve.eleve.identifiant

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
    if email && email != { "xmlns" => "" }
      query = RespLegal.where("lower(email) = ?", email.downcase)
    else
      query = RespLegal.where("lower(prenom) = ?", data["firstName"].downcase)
      nom = data["lastName"]
      query = query.where("lower(nom) = ?", nom.downcase) if nom != { "xmlns" => "" }
      if query.count > 1
        adresse = data["address"]
        query = query.where("lower(adresse) = ?", adresse.downcase) if adresse != { "xmlns" => "" }
      end
    end
    query
  end

  def debug_ent
    if @agent_connecte.super_admin?
      render xml: donnees_ent(params[:ticket])
    else
      render text: "aucun resultat sans le bon mot de passe"
    end
  end

end
