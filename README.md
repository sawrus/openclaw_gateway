# OpenClaw Gateway Docker (Orange Pi)

Готовый шаблон для:
- multi-arch сборки образа (`linux/amd64`, `linux/arm64`);
- запуска **двух контейнеров** OpenClaw Gateway на портах `10000` и `20000`;
- локального теста через `docker compose` на платформе `linux/amd64`.

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

## 3) Публикация multi-arch в registry

Перед этим войдите в нужный registry:

```bash
docker login
```

Публикация:

```bash
make push \
  DOCKER_IMAGE=ghcr.io/openclaw/openclaw \
  DOCKER_TAG=latest \
  OPENCLAW_GATEWAY_VERSION=v1.0.0
```

Команда эквивалентна вашему примеру `docker buildx build --platform linux/amd64,linux/arm64 ... --push`.

## 4) Запуск 2 контейнеров (10000 и 20000)

```bash
make pull DOCKER_PLATFORM=linux/amd64

make up \
  DOCKER_PLATFORM=linux/amd64
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

## Образ и версия по умолчанию

- По умолчанию используется образ `ghcr.io/openclaw/openclaw:latest` (`DOCKER_IMAGE` + `DOCKER_TAG` из `Makefile`).
- При необходимости можно передать другой `DOCKER_TAG` или `DOCKER_IMAGE` в `make up`/`make pull`.

## Примечания по платформе

- Для локального запуска и теста используйте только `DOCKER_PLATFORM=linux/amd64`.
- В `docker-compose.yml` платформа берется из переменной `DOCKER_PLATFORM`.
- Для buildx-сборки `make push` сохраняется multi-arch (`linux/amd64,linux/arm64`).

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
