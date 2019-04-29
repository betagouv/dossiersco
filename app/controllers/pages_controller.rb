# frozen_string_literal: true

class PagesController < ApplicationController

  def redirection_erreur
    if !eleve.nil?
      redirect_to accueil_path
    elsif !agent_connecte.nil?
      redirect_to agent_tableau_de_bord_path
    else
      redirect_to root_path
    end
  end

  def eleve
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
  end

end
