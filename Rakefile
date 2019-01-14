require_relative 'config/application'
require_relative 'lib/traitement'

Rails.application.load_tasks

desc "Lance le traitement des imports"
task :traiter_imports => :environment do
  traiter_imports
end
