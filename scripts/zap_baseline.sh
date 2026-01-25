#!/usr/bin/env bash
set -euo pipefail

# Baseline scan (passive) usando OWASP ZAP via Docker.
# Gera relatorio HTML em evidencias/zap_report.html
# Docs oficiais: zap-baseline.py esta dentro da imagem do ZAP.

TARGET_URL="${1:-http://host.docker.internal:8080}"
OUTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/evidencias"
mkdir -p "$OUTDIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERRO] docker nao encontrado." >&2
  exit 1
fi

echo "[INFO] Rodando ZAP baseline contra: $TARGET_URL"

# Observacao: em Linux, host.docker.internal pode nao existir por padrao.
# Se falhar, passe o IP do host (ex.: http://172.17.0.1:8080) ou use --network host.

# HTML (-r), JSON (-J) e Markdown (-w)
docker run --rm -t \
  -v "$OUTDIR:/zap/wrk" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
    -t "$TARGET_URL" \
    -r zap_report.html \
    -J zap_report.json \
    -w zap_report.md \
    -m 2

echo "[OK] Relatorios gerados em: $OUTDIR (zap_report.html/json/md)"
