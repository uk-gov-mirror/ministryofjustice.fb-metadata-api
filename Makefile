UID ?= $(shell id -u)
DOCKER_COMPOSE = env UID=$(UID) docker-compose -f docker-compose.yml

.PHONY: build
build:
	$(DOCKER_COMPOSE) up -d --build metadata-app

.PHONY: spec
spec: build
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test --rm  metadata-app bundle exec rspec

.PHONY: all_units
all_units: build
	$(DOCKER_COMPOSE) run --rm metadata-app bundle exec rspec --exclude-pattern spec/integration/*_spec.rb

.PHONY: unit
unit: build
  # change to what is required
	$(DOCKER_COMPOSE) run --rm metadata-app bundle exec rspec spec/requests/create_service_spec.rb

.PHONY: generate_private_key
generate_private_key:
	openssl genrsa -out ./spec/fixtures/private.pem 2048

.PHONY: generate_public_key
generate_public_key: generate_private_key
	openssl rsa -in ./spec/fixtures/private.pem -outform PEM -pubout -out ./spec/fixtures/public.pem

.PHONY: seed_public_key
seed_public_key: generate_public_key
	$(DOCKER_COMPOSE) up -d --build metatada-app-service-token-cache-redis
	docker exec metadata-app-service-token-cache-redis redis-cli set 'encoded-public-key-integration-tests' '$(shell cat ./spec/fixtures/public.pem | base64)'

.PHONY: integration
integration: build seed_public_key
	$(DOCKER_COMPOSE) run --rm metadata-app bundle exec rspec spec/integration/*_spec.rb
