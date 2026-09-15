#!/usr/bin/env bash
# Mock-сервер Prism по OpenAPI (spec/03_dev_environment.md §2).
#
# Использование:
#   tool/mock-server.sh                     # OpenAPI по умолчанию, порт 4010
#   tool/mock-server.sh path/to/openapi.yaml
#   OPENAPI=path/to/openapi.json PORT=4011 tool/mock-server.sh
#
# Prism отдаёт примеры (`example`/`examples`) из спецификации; приложение
# запускается с --dart-define=API_URL=http://localhost:${PORT}.
# Требуется Node.js (npx). Пакет скачивается при первом запуске.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# OpenAPI по умолчанию: ../pscs/src/main/resources/openapi/pscs-v2.yaml
DEFAULT_OPENAPI="$PROJECT_DIR/../pscs/src/main/resources/openapi/pscs-v2.yaml"

OPENAPI="${OPENAPI:-${1:-$DEFAULT_OPENAPI}}"
PORT="${PORT:-4010}"

if [ ! -f "$OPENAPI" ]; then
  echo "OpenAPI не найден: $OPENAPI" >&2
  echo "Укажите путь: tool/mock-server.sh <openapi.yaml|openapi.json> или OPENAPI=<путь>" >&2
  exit 1
fi

echo "Prism mock: $OPENAPI -> http://localhost:$PORT"
exec npx --yes @stoplight/prism-cli@latest mock "$OPENAPI" -p "${PORT}"
