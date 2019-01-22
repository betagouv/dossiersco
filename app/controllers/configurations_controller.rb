class ConfigurationsController < ApplicationController
  before_action :identification_agent
  before_action :if_agent_is_not_admin
  layout 'layout_configuration'

  def show
  end

  private
  def if_agent_is_not_admin
    if @agent != nil && !@agent.admin?
      redirect_to agent_tableau_de_bord_path
    elsif @agent.nil?
      redirect_to root_path
    end
  end
end