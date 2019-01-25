class AgentsController < ApplicationController
  layout 'configuration'

  before_action :identification_agent
  before_action :if_agent_is_admin

  def new
    @agent = Agent.new
  end

  def create
    @agent = Agent.new(agent_params)

    if @agent.save
      redirect_to configuration_path
    else
      render :new
    end
  end

  def index
    @agents = Agent.where(etablissement: get_agent.etablissement)
  end

  private
  def agent_params
    params.require(:agent).permit(:identifiant, :prenom, :nom, :password, :etablissement_id, :admin)
  end
end
