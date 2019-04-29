# frozen_string_literal: true

module Configuration
  class MefController < ApplicationController

    layout "configuration"

    before_action :identification_agent
    before_action :set_mef, only: %i[show edit update destroy]

    def index
      @mef = Mef.where(etablissement: agent_connecte.etablissement)
    end

    def new
      @mef = Mef.new
    end

    def edit; end

    def create
      @mef = Mef.new(mef_params)
      @mef.etablissement = agent_connecte.etablissement

      if @mef.save
        redirect_to configuration_mef_index_url, notice: t(".mef_cree")
      else
        flash[:alert] = t(".erreur_create_mef", champs: @mef.errors.first[0], erreur: @mef.errors.first[1])
        render :new
      end
    end

    def update
      if @mef.update(mef_params)
        redirect_to configuration_mef_index_url, notice: t(".mef_mis_a_jour")
      else
        render :edit
      end
    end

    def destroy
      mef_origine = DossierEleve.where(mef_origine: @mef)
      mef_destination = DossierEleve.where(mef_destination: @mef)

      if mef_origine.blank? && mef_destination.blank?
        @mef.destroy
        redirect_to configuration_mef_index_url, notice: t(".mef_supprime")
      else
        @mef = Mef.where(etablissement: agent_connecte.etablissement)
        flash[:alert] = t(".mef_utilise")
        render :index
      end
    end

    private

    def set_mef
      @mef = Mef.find(params[:id])
    end

    def mef_params
      params.require(:mef).permit(:libelle, :code, :etablissement_id)
    end

  end
end
