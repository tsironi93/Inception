ifneq (,$(wildcard .env))
	include .env
	export
endif

DC = docker-compose -p inception
COMPOSE_FILE = docker-compose.yml

.DEFAULT_GOAL := help

build:
	@echo "Building Docker images..."
	$(DC) -f $(COMPOSE_FILE) build

up: build
	@echo "Starting stack..."
	$(DC) -f $(COMPOSE_FILE) up -d

down:
	$(DC) -f $(COMPOSE_FILE) down

stop:
	$(DC) -f $(COMPOSE_FILE) stop

logs:
	$(DC) -f $(COMPOSE_FILE) logs -f

# See running containers
ps:
	$(DC) -f $(COMPOSE_FILE) ps

clean:
	$(DC) -f $(COMPOSE_FILE) down -v --remove-orphans

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
