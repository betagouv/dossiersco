class ConfigurationsController < ApplicationController
  layout 'configuration'

  before_action :identification_agent
  before_action :if_agent_is_admin

  def show
  end

end
