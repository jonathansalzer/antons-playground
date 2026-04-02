#!/usr/bin/env sh
set -eu

APP_DIR="${1:-}"
[ -n "$APP_DIR" ] || { echo "usage: $0 apps/<app-name>" >&2; exit 1; }
CARBON_FILE="$APP_DIR/carbon.yml"
[ -f "$CARBON_FILE" ] || { echo "missing $CARBON_FILE" >&2; exit 1; }

slug=$(awk -F': *' '$1=="slug" {print $2}' "$CARBON_FILE" | head -n1)
visibility=$(awk -F': *' '$1=="visibility" {print $2}' "$CARBON_FILE" | head -n1)
public_host=$(awk -F': *' '$1=="  publicHost" {print $2}' "$CARBON_FILE" | head -n1)
private_tailnet_host=$(awk -F': *' '$1=="  privateTailnetHost" {print $2}' "$CARBON_FILE" | head -n1)
private_path_prefix=$(awk -F': *' '$1=="  privatePathPrefix" {print $2}' "$CARBON_FILE" | head -n1)
health=$(awk -F': *' '$1=="  healthcheckPath" {print $2}' "$CARBON_FILE" | head -n1)
[ -n "$health" ] || health="/"
[ -n "$private_path_prefix" ] || private_path_prefix="/$slug"

if [ "$visibility" = "public" ]; then
  url="https://$public_host$health"
else
  if [ -n "$private_tailnet_host" ]; then
    tailnet_host="$private_tailnet_host"
  elif [ -n "${PRIVATE_TAILNET_HOST:-}" ]; then
    tailnet_host="$PRIVATE_TAILNET_HOST"
  else
    echo "missing domain.privateTailnetHost in $CARBON_FILE and PRIVATE_TAILNET_HOST is not set" >&2
    exit 1
  fi
  base=$(printf '%s' "$private_path_prefix" | sed 's#/$##')
  [ -n "$base" ] || base=""
  path="$health"
  if [ "$path" = "/" ]; then
    url="https://$tailnet_host$base/"
  else
    url="https://$tailnet_host$base$path"
  fi
fi

echo "smoke testing $url"
curl -fsSIL "$url"
