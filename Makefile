# Load environment variables from .env if exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Docker Compose
DC=docker-compose
PROJECT_NAME=inception

# Default target
.DEFAULT_GOAL := help

## Build containers
build:
	@echo "Building all containers..."
	$(DC) -p $(PROJECT_NAME) build

## Start containers (detached)
up:
	@echo "Starting all containers..."
	$(DC) -p $(PROJECT_NAME) up -d

## Start containers (attached)
up-attach:
	@echo "Starting all containers (attached)..."
	$(DC) -p $(PROJECT_NAME) up

## Stop containers
stop:
	@echo "Stopping all containers..."
	$(DC) -p $(PROJECT_NAME) down

## Restart containers
restart: stop up
	@echo "Containers restarted."

## Tail logs
logs:
	$(DC) -p $(PROJECT_NAME) logs -f

## Clean volumes (DANGEROUS: destroys DB)
clean:
	@echo "Stopping containers and removing volumes..."
	$(DC) -p $(PROJECT_NAME) down -v
	@echo "Cleaned up."

## Rebuild everything from scratch
rebuild: clean build up

## Show help
help:
	@echo "Makefile commands:"
	@echo "  make build        Build all containers"
	@echo "  make up           Start all containers detached"
	@echo "  make up-attach    Start all containers attached"
	@echo "  make stop         Stop all containers"
	@echo "  make restart      Restart containers"
	@echo "  make logs         Tail logs for all containers"
	@echo "  make clean        Stop containers and remove volumes"
	@echo "  make rebuild      Rebuild everything from scratch"
