module Configuration
  class AgentsController < ApplicationController
    layout 'configuration'

    before_action :identification_agent
    before_action :if_agent_is_admin

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
      @agent = Agent.find(params[:id])
    end

    def update
      @agent = Agent.find(params[:id])
      @agent.update(agent_params)
      redirect_to configuration_agents_path
    end

    private
    def agent_params
      params.require(:agent).permit(:identifiant, :prenom, :nom, :password, :etablissement_id, :admin)
    end
  end
end
