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

VOLUME_NAMES = wordpress_files wordpress_data
VOLUMES_LOCATION = ${HOME}/data/
VOLUMES = $(addprefix ${VOLUMES_LOCATION}, ${VOLUME_NAMES})

SECRET_FILES = db_root_password.txt db_password.txt cert.pem key.pem wp_admin_password.txt wp_user_password.txt
SECRETS_PATHS = $(addprefix ./secrets/, ${SECRET_FILES})

.DEFAULT_GOAL := help

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) build

up: build
	@echo "Starting stack..."
	$(SECRETS_PATHS) $(VOLUMES) build
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
	sudo rm -rf $(VOLUMES_LOCATION)

fclean: clean
	@echo "Removing images..."
	docker image prune -a -f

rebuild: clean up

$(SECRETS_PATHS):
	@echo "Error: $@ does not exists!" && exit 1

$(VOLUMES):
	mkdir -p $@

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

