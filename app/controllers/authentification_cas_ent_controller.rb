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

    dossier_eleves = []
    retrouve_liste_resp_legal(data).each do |resp_legal|
      dossier_eleves << resp_legal.dossier_eleve
    end

    if dossier_eleves.empty?
      flash[:error] = I18n.t(".dossier_non_trouver")
      redirect_to("/") && return
    elsif dossier_eleves.length == 1
      dossier_eleve = dossier_eleves[0]

      if eleve_et_etablissement_correspondant?(dossier_eleve, data)
        session[:identifiant] = dossier_eleve.eleve.identifiant

        if dossier_eleve.derniere_etape.present?
          redirect_to("/#{dossier_eleve.derniere_etape}")
        elsif dossier_eleve.etape_la_plus_avancee.present?
          redirect_to("/#{dossier_eleve.etape_la_plus_avancee}")
        else
          redirect_to("accueil")
        end
      else
        redirect_to("/", notice: "Nous n'avons pas pu retrouver votre dossier sur DossierSCO. Nous nous excusons pour ce soucis.")
      end
    else
      render :choix_dossier_eleve
    end

    nil
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

  def retrouve_dossier_eleve; end

  def eleve_et_etablissement_correspondant?(dossier_eleve, data)
    etablissements = retrouve_etablissements(data)
    enfants = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["children"]
    eleves = JSON.parse(enfants).map { |e| e["displayName"] }
    eleve_nom_complet = "#{dossier_eleve.eleve.nom.upcase} #{dossier_eleve.eleve.prenom}"
    etablissements.include?(dossier_eleve.etablissement) && eleves.include?(eleve_nom_complet)
  end

  def retrouve_etablissements(data)
    etablissements = JSON.parse(data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["structureNodes"])
    Etablissement.where("uai in (?)", etablissements.map { |e| e["UAI"] })
  end

  def retrouve_liste_resp_legal(data)
    email = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["email"]
    prenom = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["firstName"]
    nom = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["lastName"]
    adresse = data["serviceResponse"]["authenticationSuccess"]["attributes"]["userAttributes"]["address"]
    RespLegal.where(email: email, prenom: prenom, nom: nom, adresse: adresse)
  end

  def appel_direct_ent
    redirect_to "#{URL_CAS}/login?service=#{URL_RETOUR}"
  end

end
