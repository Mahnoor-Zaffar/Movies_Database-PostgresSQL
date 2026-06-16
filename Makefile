# =============================================================================
#  Makefile -- Movie Database (PostgreSQL Blueprint)
#  Common developer commands. Run `make help` for the list.
# =============================================================================

# Default values; override on the command line or via a .env file.
ENV_FILE        ?= .env
COMPOSE         ?= docker compose
DB_USER         ?= $(shell . ./$(ENV_FILE) 2>/dev/null; echo $${POSTGRES_USER:-postgres})
DB_NAME         ?= $(shell . ./$(ENV_FILE) 2>/dev/null; echo $${POSTGRES_DB:-films_db})
DB_HOST         ?= localhost
DB_PORT         ?= 5432

# All migrations, lexically sorted.
MIGRATIONS      := $(sort $(filter-out %_down.sql,$(wildcard migrations/[0-9]*.sql)))

# Make 'help' the default target.
.DEFAULT_GOAL   := help

.PHONY: help env up down restart logs ps psql wait \
        schema seed reset migrate test lint clean

## ---------------------------------------------------------------------------
help:           ## Show this help screen
	@awk 'BEGIN {FS=":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
	     /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## ---------------------------------------------------------------------------
## Environment

env:            ## Create .env from .env.example if it does not exist
	@test -f $(ENV_FILE) || (cp .env.example $(ENV_FILE) && echo "Created $(ENV_FILE) -- fill in the values.")

## ---------------------------------------------------------------------------
## Docker lifecycle

up: env         ## Start the postgres (+ adminer) stack in the background
	$(COMPOSE) up -d

down:           ## Stop the stack (preserves the data volume)
	$(COMPOSE) down

restart:        ## Restart the stack
	$(COMPOSE) restart

logs:           ## Tail the database logs
	$(COMPOSE) logs -f db

ps:             ## Show running services
	$(COMPOSE) ps

wait:           ## Block until the database accepts connections
	@echo "Waiting for postgres to become ready..."
	@until $(COMPOSE) exec -T db pg_isready -U $(DB_USER) -d $(DB_NAME) >/dev/null 2>&1; do \
		sleep 1; \
	done
	@echo "Postgres is ready."

## ---------------------------------------------------------------------------
## Database operations (run inside the running container)

psql:           ## Open an interactive psql shell
	$(COMPOSE) exec db psql -U $(DB_USER) -d $(DB_NAME)

schema: wait    ## Apply the consolidated schema.sql
	$(COMPOSE) exec -T db psql -U $(DB_USER) -d $(DB_NAME) -v ON_ERROR_STOP=1 < schema.sql

seed: wait      ## Load seed.sql into the database
	$(COMPOSE) exec -T db psql -U $(DB_USER) -d $(DB_NAME) -v ON_ERROR_STOP=1 < seed.sql

migrate: wait   ## Apply every migrations/*.sql in lexical order (skips *_down.sql)
	@for f in $(MIGRATIONS); do \
		echo "==> $$f"; \
		$(COMPOSE) exec -T db psql -U $(DB_USER) -d $(DB_NAME) -v ON_ERROR_STOP=1 < "$$f" || exit 1; \
	done

reset:          ## Wipe the database volume and re-apply schema + seed
	$(COMPOSE) down -v
	$(MAKE) up
	$(MAKE) wait
	$(MAKE) schema
	$(MAKE) seed

## ---------------------------------------------------------------------------
## Quality gates

test: wait      ## Run in-database schema and data assertions
	$(COMPOSE) exec -T db psql -U $(DB_USER) -d $(DB_NAME) -v ON_ERROR_STOP=1 < tests/test_schema_assertions.sql

lint:           ## Run sqlfluff against every tracked .sql file (requires sqlfluff)
	@command -v sqlfluff >/dev/null 2>&1 || { echo "sqlfluff not installed -- pip install sqlfluff"; exit 1; }
	sqlfluff lint --dialect postgres .

## ---------------------------------------------------------------------------
clean:          ## Remove the volume and any local junk files
	$(COMPOSE) down -v
	@find . -name '.DS_Store' -delete
	@find . -name '*.log' -delete
