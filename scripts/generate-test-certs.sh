#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="${1:-certs/local}"
CERT_FILE="${CERT_DIR}/openclaw-local.pem"
KEY_FILE="${CERT_DIR}/openclaw-local-key.pem"

mkdir -p "${CERT_DIR}"

if command -v mkcert >/dev/null 2>&1; then
  echo "[info] mkcert found, generating locally trusted certs"
  mkcert -install
  mkcert \
    -cert-file "${CERT_FILE}" \
    -key-file "${KEY_FILE}" \
    gw10000.localhost \
    gw20000.localhost \
    localhost \
    127.0.0.1 \
    ::1
else
  echo "[warn] mkcert not found, falling back to self-signed openssl cert"
  CONFIG_FILE="${CERT_DIR}/openssl.local.cnf"
  cat > "${CONFIG_FILE}" <<'CFG'
[req]
distinguished_name = dn
x509_extensions = v3_req
prompt = no

[dn]
CN = gw10000.localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = gw10000.localhost
DNS.2 = gw20000.localhost
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = ::1
CFG

  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -days 365 \
    -config "${CONFIG_FILE}" \
    -extensions v3_req
fi

chmod 600 "${KEY_FILE}"

echo "[ok] Certificate: ${CERT_FILE}"
echo "[ok] Key: ${KEY_FILE}"
