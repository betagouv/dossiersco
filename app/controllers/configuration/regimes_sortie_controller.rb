# frozen_string_literal: true

module Configuration
  class RegimesSortieController < ApplicationController

    layout "configuration"

    before_action :identification_agent
    before_action :if_agent_is_admin
    before_action :find_regime, only: %i[edit update destroy]

    def new
      @regime = RegimeSortie.new
    end

    def create
      @regime = RegimeSortie.new(params_regime.merge(etablissement: @agent_connecte.etablissement))

      if @regime.save
        redirect_to configuration_campagnes_path
      else
        flash[:alert] = t(".erreur_creation")
        render :new
      end
    end

    def edit; end

    def update
      if @regime.update(params_regime)
        redirect_to configuration_campagnes_path, notice: t(".mis_a_jour")
      else
        flash[:alert] = t(".erreur_mise_a_jour")
        render :edit
      end
    end

    def destroy
      @regime.delete
      redirect_to configuration_campagnes_path, notice: "Le régime de sortie a bien été supprimé"
    end

    private

    def params_regime
      params.require(:regime_sortie).permit(:nom, :description)
    end

    def find_regime
      @regime = RegimeSortie.find(params[:id])
    end

  end
end
