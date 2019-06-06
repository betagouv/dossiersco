# frozen_string_literal: true

module Configuration
  class CampagnesController < ApplicationController

    layout "configuration"

    before_action :identification_agent
    before_action :if_agent_is_admin, except: %i[edit update activation]
    before_action :trouve_etablissement

    def index
      @regimes = RegimeSortie.where(etablissement: @agent_connecte.etablissement).order(:nom)
      @pieces_attendues = PieceAttendue.where(etablissement: agent_connecte.etablissement)
    end

    def edit_accueil
    end

    def edit_demi_pension
    end

    def update_campagne
      if @etablissement.update(info_generales_params)
        redirect_to configuration_campagnes_path
      else
        render :edit_accueil
      end
    end

    private

    def info_generales_params
      params.require(:etablissement).permit(:gere_demi_pension, :demande_caf, :date_limite,
                                            :mot_accueil, :envoyer_aux_familles, :reglement_demi_pension)
    end

    def trouve_etablissement
      @etablissement = agent_connecte.etablissement
    end

  end
end
