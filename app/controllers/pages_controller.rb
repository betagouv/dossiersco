class PagesController < ApplicationController

  def redirection_erreur
    if !get_eleve.nil?
      redirect_to accueil_path
    elsif !get_agent.nil?
      redirect_to agent_tableau_de_bord_path
    else
      redirect_to root_path
    end
  end

  def get_eleve
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
  end

  def get_agent
    @agent ||= Agent.find_by(identifiant: session[:identifiant])
  end
end