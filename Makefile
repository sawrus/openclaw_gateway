SHELL := /bin/bash

DOCKER_IMAGE ?= ghcr.io/openclaw/openclaw
DOCKER_TAG ?= latest
DOCKER_PLATFORM ?= linux/amd64
COMPOSE_ENV_FILE ?= test.env
PLATFORMS ?= linux/amd64,linux/arm64
OPENCLAW_GATEWAY_VERSION ?= v1.0.0
RELEASE_BASE_URL ?= https://github.com/openclaw/openclaw-gateway/releases/download
BINARY_NAME ?= openclaw-gateway

.PHONY: buildx-init build push up down restart logs ps pull

buildx-init:
	docker buildx inspect --bootstrap

build: buildx-init
	DOCKER_BUILDKIT=1 docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg OPENCLAW_GATEWAY_VERSION=$(OPENCLAW_GATEWAY_VERSION) \
		--build-arg RELEASE_BASE_URL=$(RELEASE_BASE_URL) \
		--build-arg BINARY_NAME=$(BINARY_NAME) \
		--tag $(DOCKER_IMAGE):$(DOCKER_TAG) \
		--file Dockerfile \
		--load \
		.

push: buildx-init
	DOCKER_BUILDKIT=1 docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg OPENCLAW_GATEWAY_VERSION=$(OPENCLAW_GATEWAY_VERSION) \
		--build-arg RELEASE_BASE_URL=$(RELEASE_BASE_URL) \
		--build-arg BINARY_NAME=$(BINARY_NAME) \
		--tag $(DOCKER_IMAGE):$(DOCKER_TAG) \
		--file Dockerfile \
		--push \
		.

pull:
	DOCKER_IMAGE=$(DOCKER_IMAGE) DOCKER_TAG=$(DOCKER_TAG) DOCKER_PLATFORM=$(DOCKER_PLATFORM) docker compose --env-file $(COMPOSE_ENV_FILE) pull

up:
	DOCKER_IMAGE=$(DOCKER_IMAGE) DOCKER_TAG=$(DOCKER_TAG) DOCKER_PLATFORM=$(DOCKER_PLATFORM) docker compose --env-file $(COMPOSE_ENV_FILE) up -d

down:
	docker compose down

restart: down up

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps
