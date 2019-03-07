web: bundle exec rails server -p $PORT -e $RAILS_ENV
release: rake db:migrate
init: DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rake charger_donnees_exemple
