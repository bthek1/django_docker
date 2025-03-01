.PHONY: help pull-deploy push-deploy makemigrations migrate runserver createsuperuser collectstatic test install-nginx uninstall-nginx install-gunicorn uninstall-gunicorn

# Makefile

help:			## Show this help.
	@echo "Available commands:"
	@echo "For more information, see the README.md file."
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Define a guard function to check for DEBUG mode
debug_wrap:
	@if [ "$(DEBUG)" != "True" ]; then \
		echo "Error: This operation is only allowed in DEBUG mode. Set DEBUG=1 to proceed."; \
		exit 1; \
	fi

# Define project variables
PROJECT_NAME = docker_test
DOCKER_COMPOSE = docker compose


build: ## Build the Docker container
	$(DOCKER_COMPOSE) build


up: ## Start the Docker container
	$(DOCKER_COMPOSE) up -d

down: ## Stop the Docker container
	$(DOCKER_COMPOSE) down


makemigrations: ## Make migrations
	python manage.py makemigrations

migrate: makemigrations ## Apply migrations
	python manage.py migrate

runserver: migrate  ## Run the Django development server
	python manage.py runserver 0.0.0.0:8002

superuser: ## Create a superuser
	@python manage.py createsuperuser --no-input

collectstatic: ## Collect static files
	python manage.py collectstatic --noinput

test: ## Run tests
	pytest

flush: debug_wrap ## Flush the database (delete all data!) 
	@if [ -z "$(DEBUG)" ]; then python manage.py flush; else python manage.py flush --noinput; fi
  

	

clean:		## Remove pycache, tmp files and test db, mail, etc
	find . -name "*.pyc" -delete
	-find $(CURDIR) -type d -path "*__pycache__*" -not -path "*/.venv/*" -exec rm -rf {} \; #> /dev/null 2>&1
	./manage.py drop_test_database --noinput

schema:                 ## Use DRF Spectacular to generate schema for codegen to a python client
	python manage.py spectacular --api-version v1 --file schema.yaml


journal: ## View all relevant logs
	journalctl -f -n 50 -u gunicorn -u rm-queue -u rm-server -u nginx


rm-migrations: debug_wrap ## Delete all migrations
	@read -p "Delete ALL migrations? [y/N] " confirm; \
	if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
		exit 1; \
	fi
	rm **/migrations/0*.py
	rm */*/migrations/0*.py
	echo Deleted all migrations. Run 'make migrate' to recreate them.
