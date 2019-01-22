class ConfigurationsController < ApplicationController
  before_action :identification_agent
  before_action :if_agent_is_admin
  layout 'layout_configuration'

  def show
  end

end