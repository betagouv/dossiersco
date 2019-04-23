module Configuration
  class OptionsPedagogiquesController < ApplicationController
    layout 'configuration'

    before_action :identification_agent
    before_action :set_option_pedagogique, only: [:edit, :update, :destroy]

    def index
      @mefs = Mef.where(etablissement: @agent_connecté.etablissement).includes(:options_pedagogiques)
      @options_pedagogiques = OptionPedagogique.where(etablissement: @agent_connecté.etablissement)
    end

    def new
      @option_pedagogique = OptionPedagogique.new
      @mef = Mef.all
    end

    def edit
      @mef = Mef.all
    end

    def create
      @option_pedagogique = OptionPedagogique.new(option_pedagogique_params.merge(etablissement: agent_connecté.etablissement))

      if @option_pedagogique.save
        redirect_to configuration_options_pedagogiques_url, notice: t('.option_cree')
      else
        render :new
      end
    end

    def update
      if @option_pedagogique.update(option_pedagogique_params)
        redirect_to configuration_options_pedagogiques_url, notice: t('.option_mise_a_jour')
      else
        render :edit
      end
    end

    def destroy
      @option_pedagogique.destroy
      redirect_to configuration_options_pedagogiques_url, notice: t('.option_supprimee')
    end

    def ajoute_option_au_mef
      @mef = Mef.find(params[:id])
      @option = OptionPedagogique.find(params[:option])
      if @mef.options_pedagogiques.include?(@option)
        head :ok
      else
        @mef.options_pedagogiques << @option
        respond_to do |format|
          format.js{render :layout => false}
        end
      end
    end

    def enleve_option_au_mef
      @mef = Mef.find(params[:mef])
      @option = OptionPedagogique.find(params[:id])
      @mef.options_pedagogiques.delete(@option)
      respond_to do |format|
        format.js{render :layout => false}
      end
    end

    def definie_abandonnabilite
      mef_option = MefOptionPedagogique.find(params[:mef_option_pedagogique_id])
      mef_option.update(abandonnable: params[:abandonnable])
      head :ok
    end

    private
    def set_option_pedagogique
      @option_pedagogique = OptionPedagogique.find(params[:id])
    end

    def option_pedagogique_params
      params.require(:option_pedagogique).permit(:nom, :obligatoire, :groupe, {mef_ids: []})
    end
  end
end
