include .env
export

export PROJECT_ROOT = $(shell pwd)

env-up:
	docker compose up -d todoapp-postgres

env-down:
	docker compose down todoapp-postgres

env-cleanup:
	@read -p "This will remove all data in the database. Are you sure? (y/n) " answer; \
	if [ "$$answer" = "y" ]; then \
		docker compose down -v todoapp-postgres; \
		rm -rf $(PROJECT_ROOT)/out/pgdata; \
		echo "Environment cleaned."; \
	else \
		echo "Operation cancelled."; \
	fi

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Error: Migration name is required. Usage: make migrate-create name=your_migration_name"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
	create \
	-ext sql \
	-dir /migrations \
	-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down steps=1

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Error: Migration action is required. Usage: make migrate-action action=up|down"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
	-path /migrations \
	-database "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@todoapp-postgres:5432/$(POSTGRES_DB)?sslmode=disable&search_path=public" \
	"$(action)"
