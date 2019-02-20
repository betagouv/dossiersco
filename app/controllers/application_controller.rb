class ApplicationController < ActionController::Base

  def retrouve_élève_connecté
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
    if @eleve
      ajoute_information_utilisateur_pour_sentry({
        type_utilisateur: "famille",
        utilisateur: @eleve.identifiant,
        email: @eleve.email_resp_legal_1,
        etablissement: @eleve.dossier_eleve.etablissement.nom,
        code_postal: @eleve.dossier_eleve.etablissement.code_postal
      })
    else
      session[:message_erreur] = "Vous avez été déconnecté par mesure de sécurité. Merci de vous identifier avant de continuer."
      redirect_to '/'
    end
  end

  def agent_connecté
    @agent_connecté ||= Agent.find_by(identifiant: session[:identifiant])
  end

  def identification_agent
    identifiant = agent_connecté.present? ? agent_connecté.identifiant : '<anonyme>'
    ajoute_information_utilisateur_pour_sentry({
      type_utilisateur: "agent",
      utilisateur: agent_connecté.nom_complet,
      email: agent_connecté.email,
      etablissement: agent_connecté.etablissement.nom,
      code_postal: agent_connecté.etablissement.code_postal
    })
    Trace.create(identifiant: identifiant,
                 categorie: 'agent',
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
    redirect_to '/agent' unless agent_connecté.present?
  end

  def if_agent_is_admin
    if agent_connecté != nil && !agent_connecté.admin?
      redirect_to agent_tableau_de_bord_path
    elsif agent_connecté.nil?
      redirect_to root_path
    end
  end

  private
  def ajoute_information_utilisateur_pour_sentry(infos)
    Raven.user_context(user_name: infos[:utilisateur], email: infos[:email])
    Raven.tags_context({type_utilisateur: infos[:type_utilisateur], user_name: infos[:utilisateur],  etablissement: infos[:etablissement], code_postal: infos[:code_postal]})
  end

end
