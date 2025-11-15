ifneq (,$(wildcard .env))
	include .env
	export
endif

DOCKER_COMPOSE := $(shell if command -v docker-compose >/dev/null 2>&1; then echo docker-compose; \
else if command -v "docker compose" >/dev/null 2>&1; then echo "docker compose"; \
else echo ""; fi; fi)


ifeq ($(DOCKER_COMPOSE),)
$(error "Neither 'docker-compose' nor 'docker compose' command found. Please install Docker Compose.")
endif

PROJECT_NAME := inception
COMPOSE_FILE := docker-compose.yml

.DEFAULT_GOAL := help

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) build

up: build
	@echo "Starting stack..."
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) up -d

down:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) down

stop:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) stop

logs:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) logs -f

ps:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) ps

clean:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) down -v --remove-orphans

fclean: clean
	@echo "Removing images..."
	docker image prune -a -f

rebuild: clean up

help:
	@echo ""
	@echo "Available Make commands:"
	@echo "  make build        Build all images"
	@echo "  make up           Start containers"
	@echo "  make down         Stop and remove containers"
	@echo "  make stop         Stop containers (keep volumes)"
	@echo "  make ps           Show container status"
	@echo "  make logs         Show logs"
	@echo "  make clean        Remove containers + volumes"
	@echo "  make fclean       Clean + remove all images"
	@echo "  make rebuild      Full rebuild"
	@echo ""

