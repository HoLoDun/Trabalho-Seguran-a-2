#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERRO] docker nao encontrado. Instale Docker Desktop/Engine." >&2
  exit 1
fi

# Compose v2 (docker compose) ou v1 (docker-compose)
if docker compose version >/dev/null 2>&1; then
  DC=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  DC=(docker-compose)
else
  echo "[ERRO] docker compose nao encontrado (nem v2 nem v1)." >&2
  exit 1
fi

"${DC[@]}" up -d

echo
echo "DVWA iniciado. Acesse: http://localhost:8080"
echo "Primeiro setup (uma vez):"
echo "  1) Login: admin / password"
echo "  2) Clique em 'DVWA Security' e selecione 'Low'"
echo "  3) Em 'DVWA Setup', clique 'Create / Reset Database'"
