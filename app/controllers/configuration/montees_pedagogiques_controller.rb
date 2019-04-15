module Configuration
  class MonteesPedagogiquesController < ApplicationController
    layout 'configuration'

    before_action :if_agent_is_admin

    def create
      @mef_origine = Mef.find(params[:mef_origine])
      @mef_destination = Mef.find(params[:mef_destination])
      option = OptionPedagogique.find(params[:option])
      @montee = MonteePedagogique.new(mef_origine: @mef_origine, mef_destination: @mef_destination, option_pedagogique: option,
                            abandonnable: params["abandonnable-#{@mef_destination.id}"], etablissement_id: @agent_connecté.etablissement.id)
      if @montee.save!
        respond_to do |format|
          format.js{render :layout => false}
          format.html{redirect_to options_pedagogiques_path}
        end
      end
    end

    def destroy
      @montee_id = params[:id]
      MonteePedagogique.find(params[:id]).delete
      respond_to do |format|
        format.js{render :layout => false}
        format.html{redirect_to options_pedagogiques_path}
      end
    end
  end
end