require 'raven'

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

use Raven::Rack

require './dossiersco_web'
require './dossiersco_agent'

run Sinatra::Application
