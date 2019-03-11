class ConfigurationsController < ApplicationController
  layout 'configuration'

  before_action :identification_agent
  before_action :if_agent_is_admin

  def show
    stats = Struct.new(:agents, :options, :mef, :dossiers, :date_fin, :uai, :nom_etablissement, :code_postal)
    @stats = stats.new
    @stats.agents = Agent.where(etablissement: @agent_connecté.etablissement).count
  end

end
