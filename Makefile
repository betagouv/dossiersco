## Test Makefile

test: ## Run the tests
	docker-compose run --rm test

build: ## Install or update dependencies
	docker-compose build && docker-compose run --rm app rails db:migrate && docker-compose run --rm app bundle install

run: ## Start the app server
	docker-compose up app postgres

stop: ## Start the app server
	docker-compose stop

clean: ## Clean temporary files and installed dependencies
	docker-compose stop && docker-compose rm app test

console: ## Run rails console
	docker-compose run --rm app bundle exec rails c

routes: ## Run rails routes
	docker-compose run --rm app bundle exec rails routes

.PHONY: build run test clean stop
