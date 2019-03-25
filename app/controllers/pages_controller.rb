class PagesController < ApplicationController
  def a_propos
    render layout: 'famille'
  end

  def redirection_erreur
    if !get_eleve.nil?
      redirect_to accueil_path
    elsif !agent_connecté.nil?
      redirect_to agent_tableau_de_bord_path
    else
      redirect_to root_path
    end
  end

  def get_eleve
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
  end
end