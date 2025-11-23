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

# Host directories that docker-compose bind-mounts (must match docker-compose.yml driver_opts device)
VOLUME_NAMES = www db
VOLUMES_LOCATION = /home/itsiros/inception_data/
VOLUMES = $(addprefix ${VOLUMES_LOCATION}, ${VOLUME_NAMES})

SECRET_FILES = db_root_pass.txt db_user_pass.txt tls.crt tls.key wp_admin_pass.txt wp_user_pass.txt
SECRETS_PATHS = $(addprefix ./secrets/, ${SECRET_FILES})

.DEFAULT_GOAL := help

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) -f $(COMPOSE_FILE) build

up: build
	@echo "Starting stack..."
	$(MAKE) $(SECRETS_PATHS) $(VOLUMES)
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
	@# set ownership: mariadb uses UID 999 for DB dir, www-data uses UID 33 for web files
	@if echo "$@" | grep -q '/db$$'; then \
	    sudo chown -R 999:999 $@ || chown -R 999:999 $@ || true; \
	else \
	    sudo chown -R 33:33 $@ || chown -R 33:33 $@ || true; \
	fi

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