ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :mailjet
ActionMailer::Base.view_paths = File.expand_path('../../../views/mailers/', __FILE__)
