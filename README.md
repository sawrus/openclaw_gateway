# OpenClaw Gateway Docker (Orange Pi)

Готовый шаблон для:
- multi-arch сборки образа (`linux/amd64`, `linux/arm64`);
- публикации образа в Docker Hub;
- запуска **двух контейнеров** OpenClaw Gateway на портах `10000` и `20000`.

## Что в репозитории

- `Dockerfile` — образ, который скачивает бинарник стабильной версии OpenClaw Gateway из GitHub Releases.
- `docker-compose.yml` — запуск двух экземпляров сервиса.
- `Makefile` — команды для сборки, публикации и запуска.

## 1) Подготовка Docker Buildx

```bash
make buildx-init
```

## 2) Сборка multi-arch локально

> Локальная загрузка через `--load` обычно работает для одной платформы. Для multi-arch используйте `make push`.

```bash
make build \
  DOCKER_IMAGE=docker.io/<your_user>/openclaw-gateway \
  DOCKER_TAG=v1.0.0 \
  OPENCLAW_GATEWAY_VERSION=v1.0.0
```

## 3) Публикация multi-arch в Docker Hub

Перед этим войдите в Docker Hub:

```bash
docker login
```

Публикация:

```bash
make push \
  DOCKER_IMAGE=docker.io/<your_user>/openclaw-gateway \
  DOCKER_TAG=v1.0.0 \
  OPENCLAW_GATEWAY_VERSION=v1.0.0
```

Команда эквивалентна вашему примеру `docker buildx build --platform linux/amd64,linux/arm64 ... --push`.

## 4) Запуск 2 контейнеров (10000 и 20000)

```bash
make up \
  DOCKER_IMAGE=docker.io/<your_user>/openclaw-gateway \
  DOCKER_TAG=v1.0.0
```

Проверка:

```bash
make ps
```

Логи:

```bash
make logs
```

Остановка:

```bash
make down
```

## Используемая стабильная версия

По умолчанию используется `v1.0.0` (параметры `DOCKER_TAG` и `OPENCLAW_GATEWAY_VERSION`).
При необходимости укажите другой стабильный тег релиза.

## Примечания для Orange Pi

- Для Orange Pi обычно нужна платформа `linux/arm64`.
- При использовании `make push` манифест будет включать сразу `linux/amd64` и `linux/arm64`.
- На Orange Pi достаточно выполнить `make up` с тем же `DOCKER_IMAGE` и `DOCKER_TAG`.

## Git workflow (отдельная ветка)

Работайте в отдельной ветке:

```bash
git checkout -b feature/docker-orange-pi-deploy
```

Далее:

```bash
git add Dockerfile docker-compose.yml Makefile README.md
git commit -m "Add multi-arch Docker and compose setup for Orange Pi deployment"
```
