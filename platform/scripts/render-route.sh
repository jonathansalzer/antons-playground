#!/usr/bin/env sh
set -eu

APP_DIR="${1:-}"
[ -n "$APP_DIR" ] || { echo "usage: $0 apps/<app-name>" >&2; exit 1; }
CARBON_FILE="$APP_DIR/carbon.yml"
[ -f "$CARBON_FILE" ] || { echo "missing $CARBON_FILE" >&2; exit 1; }

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
PLATFORM_DIR="$ROOT_DIR/platform"

slug=$(awk -F': *' '$1=="slug" {print $2}' "$CARBON_FILE" | head -n1)
visibility=$(awk -F': *' '$1=="visibility" {print $2}' "$CARBON_FILE" | head -n1)
public_host=$(awk -F': *' '$1=="  publicHost" {print $2}' "$CARBON_FILE" | head -n1)
private_tailnet_host=$(awk -F': *' '$1=="  privateTailnetHost" {print $2}' "$CARBON_FILE" | head -n1)
service=$(awk -F': *' '$1=="  service" {print $2}' "$CARBON_FILE" | head -n1)
port=$(awk -F': *' '$1=="  internalPort" {print $2}' "$CARBON_FILE" | head -n1)
health=$(awk -F': *' '$1=="  healthcheckPath" {print $2}' "$CARBON_FILE" | head -n1)
private_path_prefix=$(awk -F': *' '$1=="  privatePathPrefix" {print $2}' "$CARBON_FILE" | head -n1)

[ -n "$slug" ] || { echo "could not parse slug from $CARBON_FILE" >&2; exit 1; }
[ -n "$visibility" ] || { echo "could not parse visibility from $CARBON_FILE" >&2; exit 1; }
[ -n "$service" ] || { echo "could not parse runtime.service from $CARBON_FILE" >&2; exit 1; }
[ -n "$port" ] || { echo "could not parse runtime.internalPort from $CARBON_FILE" >&2; exit 1; }
[ -n "$health" ] || health="/"
[ -n "$private_path_prefix" ] || private_path_prefix="/$slug"

if [ "$visibility" = "public" ]; then
  [ -n "$public_host" ] || { echo "could not parse domain.publicHost from $CARBON_FILE" >&2; exit 1; }
  out="$PLATFORM_DIR/caddy/sites/public/$slug.caddy"
  cat > "$out" <<ROUTE
$public_host {
  encode gzip
  reverse_proxy $service:$port
}
ROUTE
else
  if [ -n "$private_tailnet_host" ]; then
    tailnet_host="$private_tailnet_host"
  elif [ -n "${PRIVATE_TAILNET_HOST:-}" ]; then
    tailnet_host="$PRIVATE_TAILNET_HOST"
  else
    echo "missing domain.privateTailnetHost in $CARBON_FILE and PRIVATE_TAILNET_HOST is not set" >&2
    exit 1
  fi

  out="$PLATFORM_DIR/caddy/sites/private/$slug.caddy"
  cat > "$out" <<ROUTE
$tailnet_host {
  encode gzip
  handle_path $private_path_prefix* {
    reverse_proxy $service:$port
  }
}
ROUTE
fi

echo "wrote $out"
echo "healthcheck path: $health"
