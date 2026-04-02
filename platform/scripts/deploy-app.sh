#!/usr/bin/env sh
set -eu

APP_DIR="${1:-}"
[ -n "$APP_DIR" ] || { echo "usage: $0 apps/<app-name>" >&2; exit 1; }
[ -d "$APP_DIR" ] || { echo "missing app directory: $APP_DIR" >&2; exit 1; }

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
CARBON_FILE="$APP_DIR/carbon.yml"
COMPOSE_FILE="$APP_DIR/compose.yml"

"$SCRIPT_DIR/register-app.sh" "$APP_DIR"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "missing $COMPOSE_FILE" >&2
  exit 1
fi

network=$(awk -F': *' '$1=="    network" {print $2}' "$CARBON_FILE" | head -n1)
if [ -n "$network" ]; then
  docker network inspect "$network" >/dev/null 2>&1 || docker network create "$network" >/dev/null
fi

docker compose -f "$COMPOSE_FILE" up -d --build

echo "deployed $APP_DIR"
echo "note: private apps currently require a matching route in platform/private-router/Caddyfile"
echo "next: run docker compose up -d in platform/private-router if its config changed"
