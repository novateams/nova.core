.DEFAULT_GOAL := help
.PHONY: help stop start shell import-db clear-cache

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

stop: ## Stop containers
	docker compose down

start: ## Start daemonized containers
	docker compose up -d

restart: stop start ## Restart the containers

shell: ## Open container shell
	docker compose exec web sh

import-db: ## Import database from dump
	docker compose stop
	docker compose up -d postgresql --wait
	docker compose cp $(DUMP) postgresql:/dump.sql
	docker compose exec postgresql psql -Uprovidentia -c '\i /dump.sql'
	docker compose stop postgresql

clear-cache: ## Clear cache
	docker compose exec web bin/rails r 'Rails.cache.clear'
