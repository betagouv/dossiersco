ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def html_escape text
    ERB::Util::html_escape(text)
  end
  # Add more helper methods to be used by all tests here...
end
