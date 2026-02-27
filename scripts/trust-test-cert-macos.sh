#!/usr/bin/env bash
set -euo pipefail

CERT_FILE="${1:-certs/local/openclaw-local.pem}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[error] This script is for macOS only"
  exit 1
fi

if [[ ! -f "${CERT_FILE}" ]]; then
  echo "[error] Certificate not found: ${CERT_FILE}"
  exit 1
fi

echo "[info] Adding certificate to System keychain as trusted root (requires sudo)"
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${CERT_FILE}"

echo "[ok] Trusted: ${CERT_FILE}"
