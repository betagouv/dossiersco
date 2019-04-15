# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'fakeweb'
FakeWeb.allow_net_connect = false

class ActiveSupport::TestCase
  def html_escape(text)
    ERB::Util.html_escape(text)
  end

  def identification_agent(agent)
    post agent_url, params: { email: agent.email, mot_de_passe: agent.password }
    follow_redirect!
  end

end

require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara/minitest'

Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end


