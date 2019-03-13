module Configuration
  class MefController < ApplicationController
    layout 'configuration'

    before_action :identification_agent
    before_action :set_mef, only: [:show, :edit, :update, :destroy]

    def index
      @mef = Mef.where(etablissement: agent_connecté.etablissement)
    end

    def new
      @mef = Mef.new
    end

    def edit
    end

    def create
      @mef = Mef.new(mef_params)
      @mef.etablissement = agent_connecté.etablissement

      if @mef.save
        redirect_to configuration_mef_index_url, notice: 'Mef was successfully created.'
      else
        render :new
      end
    end

    def update
      if @mef.update(mef_params)
        redirect_to configuration_mef_index_url, notice: 'Mef was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @mef.destroy
      redirect_to configuration_mef_index_url, notice: 'Mef was successfully destroyed.'
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
