#!/usr/bin/env bash
# Генерация Dart-моделей и API-клиента из OpenAPI (P-19, plans/00 раздел 0.4).
#
# Использование:
#   tool/gen-api.sh                          # OpenAPI по умолчанию → lib/api/generated/
#   tool/gen-api.sh path/to/openapi.yaml     # другой контракт
#   OUT=/tmp/gen tool/gen-api.sh             # другая папка вывода (для проверки контракта)
#
# Генератор: openapi-generator (dart-dio) через npx @openapitools/openapi-generator-cli —
# нужны Node.js и Java 17+. Сгенерированный код коммитится в lib/api/generated/, чтобы
# сборка приложения не зависела от генератора; после генерации выполните
#   dart run build_runner build --delete-conflicting-outputs
# внутри lib/api/generated (пакет использует built_value).
#
# Правило: ничего в lib/api/generated/ не править руками — только перегенерировать.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_OPENAPI="$PROJECT_DIR/../pscs/src/main/resources/openapi/pscs-v2.yaml"
OPENAPI="${OPENAPI:-${1:-$DEFAULT_OPENAPI}}"
OUT="${OUT:-$PROJECT_DIR/lib/api/generated}"
PACKAGE_NAME="${PACKAGE_NAME:-pscs_api}"
GENERATOR_VERSION="${GENERATOR_VERSION:-7.17.0}"

if [ ! -f "$OPENAPI" ]; then
  echo "OpenAPI не найден: $OPENAPI" >&2
  exit 1
fi

echo "openapi-generator $GENERATOR_VERSION (dart-dio): $OPENAPI -> $OUT"
rm -rf "$OUT"
mkdir -p "$OUT"
npx --yes @openapitools/openapi-generator-cli@latest version-manager set "$GENERATOR_VERSION" >/dev/null
npx --yes @openapitools/openapi-generator-cli@latest generate \
  -g dart-dio \
  -i "$OPENAPI" \
  -o "$OUT" \
  --additional-properties="pubName=${PACKAGE_NAME},pubVersion=2.0.0,serializationLibrary=built_value,useEnumExtension=true,nullableFields=true" \
  --global-property="apiTests=false,modelTests=false,apiDocs=false,modelDocs=false" \
  --skip-validate-spec

echo
echo "Готово. Дальше:"
echo "  cd $OUT && dart pub get && dart run build_runner build --delete-conflicting-outputs"
