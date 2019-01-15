## Test Makefile

test: ## Run the tests
	docker-compose run --rm test

build: ## Install or update dependencies
	docker-compose build

run: ## Start the app server
	docker-compose up -d app postgres && docker-compose logs -f

clean: ## Clean temporary files and installed dependencies
	docker-compose stop && docker-compose rm app test

rails c: ## Run rails console
	docker-compose run --rm app bundle exec rails c

rails routes: ## Run rails routes
	docker-compose run --rm app bundle exec rails routes

.PHONY: build run test clean

