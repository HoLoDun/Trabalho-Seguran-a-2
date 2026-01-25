#!/usr/bin/env bash
set -euo pipefail

# Scan de configuracoes conhecidas com Nikto via Docker.
# Gera saida em evidencias/nikto.txt

TARGET_URL="${1:-http://host.docker.internal:8080}"
OUTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/evidencias"
mkdir -p "$OUTDIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERRO] docker nao encontrado." >&2
  exit 1
fi

echo "[INFO] Rodando Nikto contra: $TARGET_URL"

# Usando imagem alpine/nikto
# Saida em texto (-Format txt)
docker run --rm -t \
  -v "$OUTDIR:/out" \
  alpine/nikto:2.1.6 \
  -h "$TARGET_URL" \
  -Format txt \
  -output /out/nikto.txt

echo "[OK] Relatorio gerado em: $OUTDIR/nikto.txt"
