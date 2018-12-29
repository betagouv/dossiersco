## Test Makefile

test: ## Run the tests
	docker-compose run --rm test

build: ## Install or update dependencies
	docker-compose build

run: ## Start the app server
	docker-compose up -d app postgres && docker-compose logs -f

clean: ## Clean temporary files and installed dependencies
	docker-compose stop && docker-compose rm app test

.PHONY: build run test clean

