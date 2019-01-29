module Configuration
  class AgentsController < ApplicationController
    layout 'configuration'

    before_action :identification_agent
    before_action :if_agent_is_admin
    before_action :cherche_agent, only: [:edit, :update, :destroy]

    def new
      @agent = Agent.new
    end

    def create
      @agent = Agent.new(agent_params)
      @agent.etablissement ||= agent_connecté.etablissement

      if @agent.save
        redirect_to configuration_agents_path
      else
        render :new
      end
    end

    def index
      @agents = Agent.where(etablissement: agent_connecté.etablissement)
    end

    def edit
    end

    def update
      @agent.update(agent_params)
      redirect_to configuration_agents_path
    end

    def destroy
      @agent.destroy
      redirect_to configuration_agents_path, notice: "L'agent a bien été supprimé"
    end

    private
    def agent_params
      params.require(:agent).permit(:identifiant, :prenom, :nom, :password, :etablissement_id, :admin)
    end

    def cherche_agent
      @agent = Agent.find(params[:id])
    end
  end
end
