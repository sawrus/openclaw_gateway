SHELL := /bin/bash

DOCKER_IMAGE ?= docker.io/your_dockerhub_user/openclaw-gateway
DOCKER_TAG ?= v1.0.0
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
	DOCKER_IMAGE=$(DOCKER_IMAGE) DOCKER_TAG=$(DOCKER_TAG) docker compose pull

up:
	DOCKER_IMAGE=$(DOCKER_IMAGE) DOCKER_TAG=$(DOCKER_TAG) docker compose up -d

down:
	docker compose down

restart: down up

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps
