class ApplicationController < ActionController::Base

  def retrouve_élève_connecté
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
    unless @eleve
      session[:message_erreur] = "Vous avez été déconnecté par mesure de sécurité. Merci de vous identifier avant de continuer."
      redirect_to '/'
    end
  end

  def agent_connecté
    @agent_connecté ||= Agent.find_by(identifiant: session[:identifiant])
  end

  def identification_agent
    identifiant = agent_connecté.present? ? agent_connecté.identifiant : '<anonyme>'
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
end
