#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
APPS_DIR="$ROOT_DIR/apps"
OUT_FILE="$ROOT_DIR/platform/private-router/index.html"
TAILNET_HOST="${PRIVATE_TAILNET_HOST:-anton.tail73de9.ts.net}"

running_names=$(docker ps --format '{{.Names}}' 2>/dev/null || true)

html_header='<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Anton private apps</title>
    <style>
      body { font-family: system-ui, sans-serif; max-width: 48rem; margin: 3rem auto; padding: 0 1rem; line-height: 1.5; }
      h1 { margin-bottom: 0.5rem; }
      .muted { color: #555; }
      ul { padding-left: 1.25rem; }
      li { margin: 0.5rem 0; }
      code { background: #f3f4f6; padding: 0.1rem 0.35rem; border-radius: 0.25rem; }
    </style>
  </head>
  <body>
    <h1>Private apps</h1>
    <p class="muted">Running apps on <code>'"$TAILNET_HOST"'</code>.</p>
    <ul>'
html_footer='    </ul>
  </body>
</html>'

{
  printf '%s\n' "$html_header"

  found=0
  for carbon in "$APPS_DIR"/*/carbon.yml; do
    [ -f "$carbon" ] || continue

    app_dir=$(dirname "$carbon")
    slug=$(awk -F': *' '$1=="slug" {print $2}' "$carbon" | head -n1)
    visibility=$(awk -F': *' '$1=="visibility" {print $2}' "$carbon" | head -n1)
    service=$(awk -F': *' '$1=="  service" {print $2}' "$carbon" | head -n1)
    path_prefix=$(awk -F': *' '$1=="  privatePathPrefix" {print $2}' "$carbon" | head -n1)
    description=$(awk -F': *' '$1=="  description" {print $2}' "$carbon" | head -n1)

    [ "$visibility" = "private" ] || continue
    [ -n "$slug" ] || continue
    [ -n "$service" ] || continue
    [ -n "$path_prefix" ] || path_prefix="/$slug"

    echo "$running_names" | grep -Fx "$service" >/dev/null 2>&1 || continue

    found=1
    if [ -n "$description" ]; then
      printf '      <li><a href="%s">%s</a> — %s</li>\n' "$path_prefix" "$slug" "$description"
    else
      printf '      <li><a href="%s">%s</a></li>\n' "$path_prefix" "$slug"
    fi
  done

  if [ "$found" -eq 0 ]; then
    printf '      <li>No private apps are currently running.</li>\n'
  fi

  printf '%s\n' "$html_footer"
} > "$OUT_FILE"

echo "wrote $OUT_FILE"
