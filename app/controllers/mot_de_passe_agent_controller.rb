# frozen_string_literal: true

class MotDePasseAgentController < ApplicationController

  def new
    render :new, layout: "connexion"
  end

  def update
    agent = Agent.find_by(email: params[:email])
    service_agent = ServiceAgent.new(agent)
    if agent && service_agent.reset_mot_de_passe!
      agent = service_agent.agent
      AgentMailer.change_mot_de_passe_agent(agent).deliver_now
      flash[:notice] = t(".change_mot_de_passe_envoyee", email: agent.email)
    else
      flash[:alert] = t(".email_non_trouve", email: params[:email])
    end

    redirect_to "/agent"
  end

end
