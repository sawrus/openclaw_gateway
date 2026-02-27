# Инструкция по запуску OpenClaw Gateway

Ниже — пошаговый сценарий, который оставляет только необходимые команды и объясняет, в каком порядке их выполнять.

## 1. Подключение к устройству OPI

Подключитесь по SSH к хосту `opi`:

```bash
ssh opi
```

После подключения все последующие команды из раздела 2 выполняются уже на устройстве `opi`.

## 2. Клонирование репозитория и подготовка контейнера

Склонируйте основной репозиторий OpenClaw:

```bash
git clone https://github.com/openclaw/openclaw.git
```

Перейдите в директорию проекта (если нужно):

```bash
cd openclaw
```

Запустите скрипт настройки Docker с указанием образа:

```bash
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw ./docker-setup.sh
```

Эта команда поднимет необходимое окружение для `openclaw-gateway`.

## 3. Подключение через jump-host и проброс порта

С локальной машины откройте SSH-сессию через `vps` на `opi` с пробросом локального порта `18789`:

```bash
ssh -J vps opi -L 18789:127.0.0.1:18789
```

Это нужно для доступа к сервису на `opi` через локальный порт.

## 4. Работа с устройствами внутри контейнера gateway

Далее команды выполняются на хосте, где запущен Docker с контейнером `openclaw-openclaw-gateway-1`.

### 4.1. Показать список устройств

```bash
docker exec -it openclaw-openclaw-gateway-1 node dist/index.js devices list
```

### 4.2. Подтвердить pairing для Telegram

Вместо `XXXX` подставьте нужный код/идентификатор pairing:

```bash
docker exec -it openclaw-openclaw-gateway-1 node dist/index.js pairing approve telegram XXXX
```

### 4.3. Одобрить устройство

Вместо `YYYY` подставьте идентификатор устройства:

```bash
docker exec -it openclaw-openclaw-gateway-1 node dist/index.js devices approve YYYY
```

## Краткий порядок выполнения

1. `ssh opi`
2. `git clone https://github.com/openclaw/openclaw.git`
3. `OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw ./docker-setup.sh`
4. С локальной машины: `ssh -J vps opi -L 18789:127.0.0.1:18789`
5. `docker exec ... devices list`
6. `docker exec ... pairing approve telegram XXXX`
7. `docker exec ... devices approve YYYY`
