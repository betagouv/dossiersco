module Configuration
  class MonteesPedagogiquesController < ApplicationController
    layout 'configuration'

    before_action :if_agent_is_admin

    def create
      @mef_origine = Mef.find(params[:mef_origine])
      @mef_destination = Mef.find(params[:mef_destination])
      option = OptionPedagogique.find(params[:option])
      @montee = MonteePedagogique.new(mef_origine: @mef_origine, mef_destination: @mef_destination, option_pedagogique: option,
                            abandonnable: params["abandonnable-#{@mef_destination.id}"])
      if @montee.save!
        respond_to do |format|
          format.js{render :layout => false}
        end
      end
    end

    def destroy
      MonteePedagogique.find(params[:id]).delete
    end
  end
end