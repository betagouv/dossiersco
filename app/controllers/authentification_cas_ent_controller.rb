# frozen_string_literal: true

require "net/http"

URL_CAS = ENV["ENT_PARIS_URL"]
URL_RETOUR = ENV["ENT_PARIS_URL_RETOUR"]

class AuthentificationCasEntController < ApplicationController

  def new
    render layout: false
  end

  def retrouve_les_responsables_legaux_depuis(data)
    @resp_legals = []
    retrouve_liste_resp_legal(data).each do |resp_legal|
      @resp_legals << resp_legal
    end
  end

  def aucun_responsable_legal?
    @resp_legals.empty?
  end

  def un_seul_responsable_legal?
    @resp_legals.length == 1 && @resp_legals[0].dossier_eleve
  end

  def plusieurs_responsables_legaux?
    @resp_legals.length > 1
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

    retrouve_les_responsables_legaux_depuis(data)

    if aucun_responsable_legal?
      flash[:error] = I18n.t(".dossier_non_trouver")
      redirect_to("/") && return
    elsif un_seul_responsable_legal?
      dossier_eleve = @resp_legals[0].dossier_eleve

      identifie_et_redirige(dossier_eleve) if eleve_et_etablissement_correspondant?(dossier_eleve, data)
    elsif plusieurs_responsables_legaux?
      render :choix_dossier_eleve, layout: "connexion"
    else
      flash[:notice] = "Nous n'avons pas pu retrouver votre dossier sur DossierSCO. Nous nous excusons pour ce soucis."
      redirect_to "/"
    end
  end

  def choix_dossier
    resp_legal = RespLegal.find(params[:resp_legal])

    dossier_eleve = resp_legal.dossier_eleve

    if dossier_eleve.present?
      dossier_eleve.update(etat: "connecté") if dossier_eleve.etat == "pas connecté"
      puts "dossier_eleve identifiant: #{dossier_eleve.eleve.identifiant}"
      session[:identifiant] = dossier_eleve.eleve.identifiant

      if dossier_eleve.derniere_etape.present?
        redirect_to "/#{dossier_eleve.derniere_etape}"
      elsif dossier_eleve.etape_la_plus_avancee.present?
        redirect_to "/#{dossier_eleve.etape_la_plus_avancee}"
      else
        redirect_to "accueil"
      end

    else
      session[:message_erreur] = t("identification.erreurs.identifiants_inconnus")
      puts "ERREUR " * 20
      redirect_to root_path
    end
  end

  def donnees_ent(ticket)
    uri = URI("#{URL_CAS}/serviceValidate")
    params = { service: URL_RETOUR, ticket: ticket }
    uri.query = URI.encode_www_form(params)
    puts "uri : #{uri}"
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri)
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
    puts "data : #{data.inspect}"
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
