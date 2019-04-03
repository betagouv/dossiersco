class OptionsPedagogiquesController < ApplicationController
  layout 'configuration'

  before_action :identification_agent
  before_action :set_option_pedagogique, only: [:edit, :update, :destroy]

  def index
    @options_pedagogiques = OptionPedagogique.where(etablissement: agent_connecté.etablissement)
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
      redirect_to options_pedagogiques_url, notice: t('.option_cree')
    else
      render :new
    end
  end

  def update
    if @option_pedagogique.update(option_pedagogique_params)
      redirect_to options_pedagogiques_url, notice: t('.option_mise_a_jour')
    else
      render :edit
    end
  end

  def destroy
    @option_pedagogique.destroy
    redirect_to options_pedagogiques_url, notice: t('.option_supprimee')
  end

  private
  def set_option_pedagogique
    @option_pedagogique = OptionPedagogique.find(params[:id])
  end

  def option_pedagogique_params
    params.require(:option_pedagogique).permit(:nom, :obligatoire, :groupe, {mef_ids: []})
  end
end
