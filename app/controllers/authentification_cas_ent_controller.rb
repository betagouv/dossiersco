# frozen_string_literal: true

require "net/http"

URL_CAS = "https://ent.parisclassenumerique.fr/cas"
URL_RETOUR = if Rails.env.production?
               CGI.escape("https://dossiersco.scalingo.io/retour-ent")
             else
               CGI.escape("https://demo.dossiersco.fr/retour-ent")
             end

class AuthentificationCasEntController < ApplicationController

  def new
    render layout: false
  end

  def retour_cas
    data = donnees_ent(params[:ticket])
    dossier_eleve = retrouve_dossier_eleve(data)

    if eleve_et_etablissement_correspondant?(dossier_eleve, data)
      session[:identifiant] = dossier_eleve.eleve.identifiant

      if dossier_eleve.derniere_etape.present?
        redirect_to("/#{dossier_eleve.derniere_etape}") && return
      elsif dossier_eleve.etape_la_plus_avancee.present?
        redirect_to("/#{dossier_eleve.etape_la_plus_avancee}") && return
      else
        redirect_to("accueil") && return
      end
      return
    else
      redirect_to("/", notice: "Nous n'avons pas pu retrouver votre dossier sur DossierSCO. Nous nous excusons pour ce soucis.") && return
    end
  end

  def donnees_ent(ticket)
    url = "#{URL_CAS}/serviceValidate?service=#{URL_RETOUR}&ticket=#{ticket}"
    url = URI.parse(url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(req)
    end
    Hash.from_xml(res.body)
  end

  def eleve_et_etablissement_correspondant?(dossier_eleve, data)
    etablissement = retrouve_etablissement(data)
    enfants = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["children"]
    eleves = JSON.parse(enfants).map { |e| e["displayName"] }
    eleve_nom_complet = "#{dossier_eleve.eleve.nom.upcase} #{dossier_eleve.eleve.prenom}"
    dossier_eleve.etablissement == etablissement && eleves.include?(eleve_nom_complet)
  end

  def retrouve_etablissement(data)
    premier_etablissement = JSON.parse(data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["structureNodes"])[0]
    Etablissement.find_by(uai: premier_etablissement["UAI"])
  end

  def retrouve_dossier_eleve(data)
    email = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["email"]
    prenom = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["firstName"]
    nom = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["lastName"]
    adresse = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["address"]
    resp_legal = RespLegal.find_by(email: email, prenom: prenom, nom: nom, adresse: adresse)
    unless resp_legal
      redirect_to("/", error: "Nous n'avons pas pu retrouver votre dossier sur DossierSCO. Nous nous excusons pour ce soucis.") && return
    end
    resp_legal.dossier_eleve
  end

  def appel_direct_ent
    redirect_to "#{URL_CAS}/login?service=#{URL_RETOUR}"
  end

end
