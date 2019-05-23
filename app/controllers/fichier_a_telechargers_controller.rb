# frozen_string_literal: true

class FichierATelechargersController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def show
    fichier = FichierATelecharger.find(params[:id])
    if @agent_connecte.etablissement == fichier.etablissement
      redirect_to fichier.contenu.url
    else
      flash[:alert] = "Veuillez vous connecter pour pouvoir télécharger le dossier"
      redirect_to agent_tableau_de_bord_path
    end
  end
end
