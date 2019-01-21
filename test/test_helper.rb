ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase

  def html_escape text
    ERB::Util::html_escape(text)
  end

  def identification_agent(agent)
    post agent_url, params: {identifiant: agent.identifiant, mot_de_passe: agent.password}
    follow_redirect!
  end


end