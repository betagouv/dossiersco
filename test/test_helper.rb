# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "webmock/minitest"
WebMock.disable_net_connect!

module ActiveSupport
  class TestCase

    def html_escape(text)
      ERB::Util.html_escape(text)
    end

    def identification_agent(agent = nil)
      post agent_url, params: { email: agent.email, mot_de_passe: agent.password }
      follow_redirect!
    end

    def identification_agent_avec_responsables_uploaded
      etablissement = Fabricate(:etablissement_avec_responsables_uploaded)
      admin = Fabricate(:admin, etablissement: etablissement)
      identification_agent(admin)
      admin.etablissement
    end

  end
end

require "capybara/rails"
require "capybara/poltergeist"
require "capybara/minitest"

Capybara.javascript_driver = :poltergeist

module ActionDispatch
  class IntegrationTest

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
end
