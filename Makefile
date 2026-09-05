SHELL := /bin/sh

UV ?= uv
COMPOSE ?= docker compose
API_DIR := services/api
WEB_DIR := apps/web
MOBILE_DIR := apps/mobile

.DEFAULT_GOAL := help

.PHONY: help infra-up infra-down infra-reset infra-logs api-install api-migrate api-migrations-check api-run api-worker api-dispatch api-lint api-test api-check web-install web-dev web-check mobile-install mobile-run mobile-check mobile-release-smoke check config-check

help: ## Show the available commands.
	@awk 'BEGIN {FS = ":.*## "; printf "DukaanAI development commands\n\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

infra-up: ## Start local PostgreSQL and Valkey.
	$(COMPOSE) up -d --wait postgres redis

infra-down: ## Stop local infrastructure without deleting data.
	$(COMPOSE) down

infra-reset: ## Delete local infrastructure data and start clean (destructive).
	@printf "This deletes local DukaanAI PostgreSQL and Valkey volumes. Type RESET to continue: "; read answer; [ "$$answer" = "RESET" ]
	$(COMPOSE) down --volumes

infra-logs: ## Follow local infrastructure logs.
	$(COMPOSE) logs --follow postgres redis

api-install: ## Install the API and development dependencies.
	cd $(API_DIR) && $(UV) sync --locked

api-migrate: ## Apply Django database migrations.
	cd $(API_DIR) && $(UV) run --locked python manage.py migrate --noinput

api-migrations-check: ## Fail when model changes lack a migration.
	cd $(API_DIR) && $(UV) run --locked python manage.py makemigrations --check --dry-run

api-run: ## Run the Django development server.
	cd $(API_DIR) && $(UV) run --locked python manage.py runserver 0.0.0.0:8000

api-worker: ## Run the Celery worker.
	cd $(API_DIR) && $(UV) run --locked celery -A config worker --loglevel=INFO

api-dispatch: ## Dispatch one batch of scheduled work.
	cd $(API_DIR) && $(UV) run --locked python manage.py dispatch_scheduled

api-lint: ## Lint and check formatting for the API.
	cd $(API_DIR) && $(UV) run --locked ruff check . && $(UV) run --locked ruff format --check .

api-test: ## Run API tests.
	cd $(API_DIR) && $(UV) run --locked pytest

api-check: api-migrations-check api-lint api-test ## Run all API checks.

web-install: ## Install the stable-host web client dependencies reproducibly.
	npm ci

web-dev: ## Run the stable-host web client.
	npm run dev:web

web-check: ## Type-check, test, and build the stable-host web client.
	npm run lint:web
	npm run test:web
	npm run build:web

mobile-install: ## Install Flutter dependencies.
	cd $(MOBILE_DIR) && flutter pub get

mobile-run: ## Run the Flutter app on a connected target.
	cd $(MOBILE_DIR) && flutter run

mobile-check: ## Analyze and test the Flutter client.
	cd $(MOBILE_DIR) && flutter analyze && flutter test

mobile-release-smoke: ## Compile a release APK against DUKAAN_API_BASE_URL.
	@test -n "$(DUKAAN_API_BASE_URL)" || (echo "DUKAAN_API_BASE_URL is required" >&2; exit 2)
	cd $(MOBILE_DIR) && flutter build apk --release --dart-define=DUKAAN_API_BASE_URL=$(DUKAAN_API_BASE_URL)

check: api-check web-check mobile-check ## Run all repository checks.

config-check: ## Parse YAML and validate Compose when Docker is available.
	ruby -e 'require "yaml"; ARGV.each { |path| YAML.safe_load(File.read(path), [], [], true); puts "valid YAML: #{path}" }' compose.yaml render.yaml .github/workflows/ci.yml .github/workflows/security.yml .github/dependabot.yml
	@if command -v docker >/dev/null 2>&1; then $(COMPOSE) config --quiet; else echo "docker unavailable; skipped Compose semantic validation"; fi
