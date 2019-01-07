class AccueilController < ApplicationController

  def index
  end

  def identification
    if params[:identifiant].empty? || params[:annee].empty? || params[:mois].empty? || params[:jour].empty?
      session[:message_erreur] = "Veuillez renseigner l'identifiant et la date de naissance de l'élève."
      redirect_to '/'
    end
    Trace.create(identifiant: params[:identifiant],
                 categorie: 'famille',
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
    identifiant = normalise_alphanum params[:identifiant]
    dossier_eleve = get_dossier_eleve identifiant

    date_saisie = "#{params[:annee]}-#{params[:mois]}-#{params[:jour]}"
    if dossier_eleve.present? && (dossier_eleve.eleve.date_naiss == date_saisie)
      if dossier_eleve.etat == 'pas connecté'
        dossier_eleve.update(etat: 'connecté')
      end
      session[:identifiant] = identifiant
      if dossier_eleve.derniere_etape.present?
        redirect_to "/#{dossier_eleve.derniere_etape}"
      elsif dossier_eleve.etape_la_plus_avancee.present?
        redirect_to "/#{dossier_eleve.etape_la_plus_avancee}"
      else
        redirect_to "accueil"
      end

    else
      # Emettre un message générique quelle que soit l'erreur pour éviter
      # de "fuiter" de l'information sur l'existence ou non des identifiants
      session[:message_erreur] = "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
      redirect_to '/'
    end
  end

  def accueil
    eleve.dossier_eleve.update derniere_etape: 'accueil'
    @dossier_eleve = eleve.dossier_eleve
  end

  private
  def normalise_alphanum chaine
    chaine.gsub(/[^[:alnum:]]/, '').upcase
  end

  def get_dossier_eleve identifiant
    DossierEleve.joins(:eleve).find_by(eleves: {identifiant: identifiant})
  end

  def eleve
    Eleve.find_by(identifiant: session[:identifiant])
  end

end
