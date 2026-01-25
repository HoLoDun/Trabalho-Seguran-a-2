#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if docker compose version >/dev/null 2>&1; then
  DC=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  DC=(docker-compose)
else
  echo "[ERRO] docker compose nao encontrado." >&2
  exit 1
fi

"${DC[@]}" down

echo "DVWA parado e containers removidos."
