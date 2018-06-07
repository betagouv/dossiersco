class StagingInterceptor
  def self.delivering_email(message)
    original_to = message.to.inspect
    message.to = ['contact@dossiersco.beta.gouv.fr']
    message.subject = "#{message.subject} #{original_to}"
  end
end

configure :staging do
    ActionMailer::Base.register_interceptor(StagingInterceptor)
end

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :mailjet
ActionMailer::Base.view_paths = File.expand_path('../../../views/mailers/', __FILE__)

configure :development do
  ActionMailer::Base.delivery_method = :test
end