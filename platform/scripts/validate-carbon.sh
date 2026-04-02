#!/usr/bin/env sh
set -eu

APP_DIR="${1:-}"
[ -n "$APP_DIR" ] || { echo "usage: $0 apps/<app-name>" >&2; exit 1; }
CARBON_FILE="$APP_DIR/carbon.yml"
[ -f "$CARBON_FILE" ] || { echo "missing $CARBON_FILE" >&2; exit 1; }

require_key() {
  key="$1"
  if ! grep -Eq "^[[:space:]]*$key:" "$CARBON_FILE"; then
    echo "missing required key: $key" >&2
    exit 1
  fi
}

require_key version
require_key name
require_key slug
require_key stack
require_key visibility
require_key service
require_key internalPort
require_key healthcheckPath

visibility=$(awk -F': *' '$1=="visibility" {print $2}' "$CARBON_FILE" | head -n1)
case "$visibility" in
  private|public) ;;
  *) echo "visibility must be private or public" >&2; exit 1 ;;
esac

if [ "$visibility" = "public" ]; then
  require_key publicHost
else
  require_key privatePathPrefix
fi

echo "validated $CARBON_FILE"
