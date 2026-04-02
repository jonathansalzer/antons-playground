#!/usr/bin/env sh
set -eu

APP_DIR="${1:-}"
[ -n "$APP_DIR" ] || { echo "usage: $0 apps/<app-name>" >&2; exit 1; }

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
"$SCRIPT_DIR/validate-carbon.sh" "$APP_DIR"
"$SCRIPT_DIR/render-route.sh" "$APP_DIR"

CARBON_FILE="$APP_DIR/carbon.yml"
visibility=$(awk -F': *' '$1=="visibility" {print $2}' "$CARBON_FILE" | head -n1)
slug=$(awk -F': *' '$1=="slug" {print $2}' "$CARBON_FILE" | head -n1)
public_host=$(awk -F': *' '$1=="  publicHost" {print $2}' "$CARBON_FILE" | head -n1)
private_tailnet_host=$(awk -F': *' '$1=="  privateTailnetHost" {print $2}' "$CARBON_FILE" | head -n1)
private_path_prefix=$(awk -F': *' '$1=="  privatePathPrefix" {print $2}' "$CARBON_FILE" | head -n1)
[ -n "$private_path_prefix" ] || private_path_prefix="/$slug"

echo "app registration scaffold complete for $APP_DIR"
if [ "$visibility" = "public" ]; then
  echo "public URL: https://$public_host"
else
  if [ -n "$private_tailnet_host" ]; then
    echo "private URL: https://$private_tailnet_host$private_path_prefix"
  else
    echo "private URL: https://<set-domain.privateTailnetHost-or-PRIVATE_TAILNET_HOST>$private_path_prefix"
  fi
fi

echo "next: reload the shared Caddy service so the new route is picked up"
