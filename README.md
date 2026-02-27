# OpenClaw Gateway через WSS (TLS) без публикации backend-портов

Реализован вариант A (предпочтительный): отдельные сабдомены под каждый gateway.

- `wss://gw10000.example.com` -> `gateway-10000:18789` (внутри Docker-сети)
- `wss://gw20000.example.com` -> `gateway-20000:18789` (внутри Docker-сети)

В интернет публикуется только reverse-proxy (`80/443`). Порты backend `10000/20000` не публикуются вообще.

## Файлы

- `docker-compose.yml` - два gateway + Caddy reverse proxy
- `Caddyfile` - TLS (Let's Encrypt), WSS proxy, IP allowlist

## 1) Подготовка переменных (обязательно)

Создайте `.env` рядом с `docker-compose.yml`:

```bash
cat > .env <<'EOF'
DOCKER_IMAGE=ghcr.io/openclaw/openclaw
DOCKER_TAG=latest
DOCKER_PLATFORM=linux/amd64

ACME_EMAIL=admin@example.com
ACME_CA=https://acme-v02.api.letsencrypt.org/directory
DOMAIN_GW10000=gw10000.example.com
DOMAIN_GW20000=gw20000.example.com

# Один IP или CIDR, например: 203.0.113.10/32
ALLOW_IPS=203.0.113.10/32

# ОБЯЗАТЕЛЬНО: сильный токен
OPENCLAW_GATEWAY_TOKEN=REPLACE_ME
EOF
```

`ACME_EMAIL` должен быть реальным адресом (не `example.com`), иначе CA отклонит регистрацию ACME account.

Сгенерировать безопасный токен:

```bash
openssl rand -hex 32
```

Вставьте результат в `OPENCLAW_GATEWAY_TOKEN`. Пустое значение не пройдет: compose остановится с ошибкой.

## 2) DNS

Нужны записи:

- `A` (и/или `AAAA`) для `gw10000.example.com` -> публичный IP вашего хоста
- `A` (и/или `AAAA`) для `gw20000.example.com` -> публичный IP вашего хоста

Важно: домены должны уже резолвиться на сервер до первого старта Caddy, иначе Let's Encrypt не выдаст сертификат.

## 3) Запуск

```bash
docker compose up -d
docker compose ps
```

Проверка TLS handshake:

```bash
curl -vk https://gw10000.example.com
curl -vk https://gw20000.example.com
```

## 4) Подключение клиента

Используйте только доменные WSS URL:

- `wss://gw10000.example.com`
- `wss://gw20000.example.com`

Не используйте `0.0.0.0` в URL.

## 5) Проверка, что backend не торчит в интернет

На сервере:

```bash
docker compose ps
ss -tulpen | grep -E '(:10000|:20000|:443|:80)\b'
```

Ожидаемо: слушают только `:80` и `:443` (reverse proxy). Портов `10000/20000` на хосте быть не должно.

Из внешней сети (другой хост/интернет):

```bash
nc -vz <your_server_ip> 10000
nc -vz <your_server_ip> 20000
```

Ожидаемо: `failed`/`timed out`.

## 6) Ограничение доступа и anti-abuse

Уже включено в `Caddyfile`:

- IP allowlist через `remote_ip` matcher (`ALLOW_IPS`)

По rate limit:

- в стандартном Caddy нет встроенного rate-limit без доп. модуля;
- для простого копипаста рекомендуется держать allowlist + firewall/cloud edge rate limit.
- пример на хосте с UFW:

```bash
sudo ufw limit 443/tcp
```

## 7) Troubleshooting TLS error

Типовые причины:

- hostname не совпадает с сертификатом  
  Пример: сертификат на `gw10000.example.com`, а клиент подключается к IP или другому домену.
- попытка подключиться к backend напрямую (`ws://...:10000`/`20000`) вместо `wss://...` через proxy
- использование `0.0.0.0` в клиентском URL
- DNS еще не обновился, и домен не указывает на этот сервер
- порт `443` закрыт firewall/NAT
- `ALLOW_IPS` не содержит ваш текущий IP, поэтому proxy отдает `403`

## Локальный тест на macOS (до деплоя на Orange Pi)

Добавлены отдельные файлы:

- `docker-compose.test.yml`
- `Caddyfile.test`
- `test.local.env`
- `scripts/generate-test-certs.sh`
- `scripts/trust-test-cert-macos.sh`

Шаги:

```bash
# 1) Сгенерировать локальные сертификаты
./scripts/generate-test-certs.sh

# 2) (опционально) добавить сертификат в доверенные на macOS
./scripts/trust-test-cert-macos.sh

# 3) Поднять локальный тестовый стек
docker compose -f docker-compose.test.yml --env-file test.local.env up -d

# 4) Проверить TLS и WSS endpoints
curl -vk https://gw10000.localhost:8443
curl -vk https://gw20000.localhost:8443
```

Если видите `HTTP/2 403 Forbidden`, TLS уже работает, а блокирует только IP allowlist.
Для локального теста в `test.local.env` стоит `ALLOW_IPS=0.0.0.0/0 ::/0`.

Проверка, что backend не опубликован:

```bash
docker compose -f docker-compose.test.yml --env-file test.local.env ps
lsof -nP -iTCP -sTCP:LISTEN | grep -E ':(10000|20000|443|80)\b'
```

Ожидаемо: только `127.0.0.1:8080` и `127.0.0.1:8443`, без `10000/20000`.
