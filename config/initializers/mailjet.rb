# frozen_string_literal: true

Mailjet.configure do |config|
  config.api_key = ENV["MAILER_API_KEY"]
  config.secret_key = ENV["MAILER_SECRET_KEY"]
  config.default_from = "equipe@dossiersco.fr"
end
