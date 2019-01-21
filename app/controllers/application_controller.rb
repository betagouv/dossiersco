class ApplicationController < ActionController::Base
  def get_agent
    @agent ||= Agent.find_by(identifiant: session[:identifiant])
  end

  def identification_agent
    agent_connecte = get_agent
    identifiant = agent_connecte.present? ? agent_connecte.identifiant : '<anonyme>'
    Trace.create(identifiant: identifiant,
                 categorie: 'agent',
                 page_demandee: request.path_info,
                 adresse_ip: request.ip)
    redirect_to '/agent' unless agent_connecte.present?
  end

end
