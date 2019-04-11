module Configuration
  class MonteesPedagogiquesController < ApplicationController
    layout 'configuration'

    before_action :if_agent_is_admin
<<<<<<< HEAD
    before_action :set_montee_pedagogique, only: [:edit, :update, :destroy]
=======
>>>>>>> permet d'ajouter des montées pédagogiques

    def create
      @mef_origine = Mef.find(params[:mef_origine])
      @mef_destination = Mef.find(params[:mef_destination])
      option = OptionPedagogique.find(params[:option])
      @montee = MonteePedagogique.new(mef_origine: @mef_origine, mef_destination: @mef_destination, option_pedagogique: option,
<<<<<<< HEAD
                            abandonnable: params["abandonnable-#{@mef_destination.id}"], etablissement_id: @agent_connecté.etablissement.id)
      if @montee.save!
        respond_to do |format|
          format.js{render :layout => false}
          format.html{redirect_to options_pedagogiques_path}
=======
                            abandonnable: params["abandonnable-#{@mef_destination.id}"])
      if @montee.save!
        respond_to do |format|
          format.js{render :layout => false}
>>>>>>> permet d'ajouter des montées pédagogiques
        end
      end
    end

<<<<<<< HEAD
    def edit
      @montee_pedagogique = MonteePedagogique.find(params[:id])
    end

    def update
      @montee_pedagogique.update(montee_pedagogique_params)
      redirect_to options_pedagogiques_path
    end

    def destroy
      @montee_id = @montee_pedagogique.id
      @montee_pedagogique.delete
      respond_to do |format|
        format.js{render :layout => false}
        format.html{redirect_to options_pedagogiques_path}
      end
    end

    private

    def set_montee_pedagogique
      @montee_pedagogique = MonteePedagogique.find(params[:id])
    end

    def montee_pedagogique_params
      params.require(:montee_pedagogique).permit(:abandonnable, :groupe)
=======
    def destroy
      MonteePedagogique.find(params[:id]).delete
>>>>>>> permet d'ajouter des montées pédagogiques
    end
  end
end